//
//  CommentTreeNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CommentTreeNodeDelegate: class {
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, commentIdentifier: String)
  func commentTreeDidPerformAction(_ commentTreeNode: CommentTreeNode, commentIdentifier: String, action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?)
  func commentTreeParentIdentifier(_ node: CommentTreeNode, commentIdentifier: String) -> String?
  func commentTreeInfo(_ node: CommentTreeNode, commentIdentifier: String) -> CommentInfo?
  func commentTreeRepliesCount(_ node: CommentTreeNode, commentIdentifier: String) -> Int
  func commentTreeRepliesInfo(_ node: CommentTreeNode, commentIdentifier: String) -> [CommentInfo]
}

class CommentTreeNode: ASCellNode {
  let commentNode: CommentNode
  let viewRepliesDisclosureNode: DisclosureNode
  fileprivate var highlightNode: HighlightNode?
  
  var commentNodeThatNeedsHighlight: ASDisplayNode?
  
  fileprivate(set) var mode: DisplayMode = .normal
  
  var commentIdentifier: String! {
    didSet {
      refreshCommentNode()
      refreshDisclosureNodeText()
    }
  }
  var replyCommentsIdentifiers: [String]
  
  /**
   Holding the comments node in an array turned to be required
   For the highlight mechanism to function
   Otherwise when the comments tree node re-layout itself
   the freshly created comments nodes in `layoutSpecThatFits` still have
   no supernode, and insertin the highlighted node behind it will
   lead to a failure
   */
  fileprivate var replyCommentsNodes: [CommentNode]
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  var isReplyTree: Bool {
    get {
      return configuration.isReplyTree
    }
    set {
      configuration.isReplyTree = newValue
    }
  }
  
  weak var delegate: CommentTreeNodeDelegate?
  
  //MARK: LIFE CYCLE
  //================
  override init() {
    commentNode = CommentNode()
    viewRepliesDisclosureNode = DisclosureNode()
    replyCommentsIdentifiers = []
    replyCommentsNodes = []
    super.init()
    initializeNode()
  }
  
  func initialize(with mode: DisplayMode) {
    self.mode = mode
    refreshCommentNodeMode()
    refreshReplyCommentNodes()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    commentNode.delegate = self
    
    var disclosureNodeConfiguration = DisclosureNode.Configuration()
    disclosureNodeConfiguration.style = .highlighted
    disclosureNodeConfiguration.nodeEdgeInsets.left = 0
    disclosureNodeConfiguration.imageNodeInsets.right = 0
    viewRepliesDisclosureNode.configuration = disclosureNodeConfiguration
    viewRepliesDisclosureNode.delegate = self
  }
  
  //MARK: LAYOUT
  //============
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var elements: [ASLayoutElement] = []
    let parentCommentInsets: ASInsetLayoutSpec
    if isReplyTree {
      parentCommentInsets = ASInsetLayoutSpec(
        insets: configuration.replyCommentIndentation, child: commentNode)
    } else {
      parentCommentInsets = ASInsetLayoutSpec(
        insets: configuration.internalInsets, child: commentNode)
    }
    elements.append(parentCommentInsets)
    
    switch mode {
    case .normal:
      if !isReply, hasReplies {
        for replyCommentNode in replyCommentsNodes {
          elements.append(separator())
          let replyCommentInsets = ASInsetLayoutSpec(
            insets: configuration.replyCommentIndentation, child: replyCommentNode)
          elements.append(replyCommentInsets)
        }
        
        if hasAdditionalReplies {
          elements.append(separator())
          let disclosureNodeInsets = ASInsetLayoutSpec(
            insets: configuration.disclosureNodeInsets, child: viewRepliesDisclosureNode)
          elements.append(disclosureNodeInsets)
        }
      }
    case .parentOnly, .minimal:
      break
    }
    
    let treeStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .start,
      alignItems: .stretch,
      children: elements)
    
    // Add Top Separator
    let finalLayout = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .start,
      alignItems: .stretch,
      children: [separator(), treeStack])
    return finalLayout
  }
  
  override func layoutDidFinish() {
    super.layoutDidFinish()
    handleHighlightOperation()
  }
  
  func refreshCommentNode() {
    guard let commentInfo = delegate?.commentTreeInfo(self, commentIdentifier: commentIdentifier) else {
      return
    }
    commentNode.imageURL = commentInfo.avatarURL
    commentNode.fullName = commentInfo.fullName
    commentNode.message = commentInfo.message
    commentNode.setWitValue(
      witted: commentInfo.isWitted,
      numberOfWits: commentInfo.numberOfWits)
    commentNode.date = commentInfo.createdAt
    refreshReplyCommentNodes()
    refreshCommentNodeMode()
    setNeedsLayout()
  }
  
  fileprivate func refreshCommentNodeMode() {
    commentNode.mode = (mode == .minimal) ? .minimal : (isReply ? .reply : .normal)
    setNeedsLayout()
  }
  
  fileprivate func refreshReplyCommentNodes() {
    replyCommentsIdentifiers.removeAll()
    replyCommentsNodes.removeAll()
    switch mode {
    case .normal:
      if let replyCommentsInformation = delegate?.commentTreeRepliesInfo(self, commentIdentifier: commentIdentifier).prefix(configuration.maximumRepliesDisplayed) {
        replyCommentsIdentifiers = replyCommentsInformation.map({ $0.id })
        for replyInfo in replyCommentsInformation {
          let replyCommentNode = CommentNode()
          replyCommentNode.mode = .reply
          replyCommentNode.delegate = self
          replyCommentNode.imageURL = replyInfo.avatarURL
          replyCommentNode.fullName = replyInfo.fullName
          replyCommentNode.message = replyInfo.message
          replyCommentNode.setWitValue(
            witted: replyInfo.isWitted,
            numberOfWits: replyInfo.numberOfWits)
          replyCommentNode.date = replyInfo.createdAt
          replyCommentsNodes.append(replyCommentNode)
        }
      }
    default:
      return
    }
    setNeedsLayout()
  }
  
  func refreshDisclosureNodeText() {
    viewRepliesDisclosureNode.text = Strings.view_all_replies(number: repliesCount)
    setNeedsLayout()
  }
  
  //MARK: APIs
  //==========
  var hasReplies: Bool {
    return repliesCount > 0
  }
  
  /// Additional replies are not displayed
  var hasAdditionalReplies: Bool {
    return repliesCount > configuration.maximumRepliesDisplayed
  }
  
  var isReply: Bool {
    return !(delegate?.commentTreeParentIdentifier(self, commentIdentifier: commentIdentifier) ?? "").isEmptyOrNil()
  }
  
  //MARK: HELPERS
  //=============
  fileprivate func addComment(identifier: String, at index: Int) {
    guard let commentInfo = delegate?.commentTreeInfo(self, commentIdentifier: identifier) else {
      return
    }
    
    let replyCommentNode = CommentNode()
    replyCommentNode.mode = .reply
    replyCommentNode.delegate = self
    replyCommentNode.imageURL = commentInfo.avatarURL
    replyCommentNode.fullName = commentInfo.fullName
    replyCommentNode.message = commentInfo.message
    replyCommentNode.setWitValue(
      witted: commentInfo.isWitted,
      numberOfWits: commentInfo.numberOfWits)
    replyCommentNode.date = commentInfo.createdAt
    replyCommentsNodes.insert(replyCommentNode, at: 0)
    replyCommentsIdentifiers.insert(identifier, at: index)
    setNeedsLayout()
    
    if replyCommentsNodes.count > configuration.maximumRepliesDisplayed {
      guard let lastCommentIdentifier = replyCommentsIdentifiers.last,
        let indexOfLastCommentIdentifier = replyCommentsIdentifiers.index(of: lastCommentIdentifier) else {
          fatalError("CommentTreeNode: Trying to remove a comment")
      }
      removeComment(identifier: lastCommentIdentifier, at: indexOfLastCommentIdentifier)
    }
    
    refreshDisclosureNodeText()
  }
  
  fileprivate func removeComment(identifier: String, at index: Int) {
  }
  
  fileprivate var repliesCount: Int {
    return delegate?.commentTreeRepliesCount(self, commentIdentifier: commentIdentifier) ?? 0
  }
  
  fileprivate func handleHighlightOperation() {
    if let nodeNeedsHighlight = self.commentNodeThatNeedsHighlight {
      self.commentNodeThatNeedsHighlight = nil
      highlight(node: nodeNeedsHighlight)
    } else if let highlightNode = self.highlightNode {
      self.highlightNode = nil
      highlightNode.startCoolDown(completion: nil)
    }
  }
  
  fileprivate func highlight(node: ASDisplayNode) {
    if let previousHighlightNode = self.highlightNode {
      previousHighlightNode.startCoolDown(completion: nil)
    }
    self.highlightNode = HighlightNode()
    self.highlightNode?.frame = wideFrame(forCommentNode: node)
    insertSubnode(self.highlightNode!, belowSubnode: node)
  }
  
  fileprivate func separator() -> ASDisplayNode {
    let separator = ASDisplayNode()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1)
    return separator
  }
  
  fileprivate func wideFrame(forCommentNode node: ASDisplayNode) -> CGRect {
    var nodeFrame = node.frame
    nodeFrame.size.height += configuration.internalInsets.top + configuration.internalInsets.bottom
    nodeFrame.size.width = frame.width
    nodeFrame.origin.x = 0
    nodeFrame.origin.y -= configuration.internalInsets.top
    return nodeFrame
  }
}

                                  //******\\

// MARK: - Display Mode
extension CommentTreeNode {
  enum DisplayMode {
    case normal
    case parentOnly
    case minimal
  }
}

                                  //******\\

// MARK: - Configuration
extension CommentTreeNode {
  struct Configuration {
    fileprivate let replyCommentIndentation = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: CommentNode.Configuration().imageReservedHorizontalSpace
        + ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var internalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var disclosureNodeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var highlightColor = ThemeManager.shared.currentTheme.colorNumber5()
    var isReplyTree: Bool = false
    var defaultColor = UIColor.white
    var maximumRepliesDisplayed = 10
  }
}

                                  //******\\

// MARK: - Comment node delegate
extension CommentTreeNode: CommentNodeDelegate {
  func commentNode(_ node: CommentNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    // Detect the comment responsible for the action for it could be the parent
    // Comment or any of the replies that are visible within the commentTreeNode
    var targetCommentID: String?
    if node === commentNode {
      targetCommentID = commentIdentifier
    } else {
      for (index, replyCommentNode) in replyCommentsNodes.enumerated() {
        if node === replyCommentNode, index < replyCommentsIdentifiers.count {
          targetCommentID = replyCommentsIdentifiers[index]
        }
      }
    }

    guard let commentIdentifier = targetCommentID else {
      return
    }
    delegate?.commentTreeDidPerformAction(self, commentIdentifier: commentIdentifier, action: action, forSender: sender, didFinishAction: didFinishAction)
  }
  
  func commentNodeUpdateLayout(_ node: CommentNode, forExpandedState state: DynamicCommentMessageNode.DynamicMode) {
    commentNodeThatNeedsHighlight = node
    setNeedsLayout()
  }
}

                                  //******\\

// MARK: - Disclosure node delegate
extension CommentTreeNode: DisclosureNodeDelegate {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool) {
    delegate?.commentTreeDidTapViewReplies(self, commentIdentifier: commentIdentifier)
  }
}
