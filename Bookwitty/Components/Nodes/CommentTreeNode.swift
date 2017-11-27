//
//  CommentTreeNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CommentTreeNodeDelegate: class {
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, comment: Comment)
  func commentTreeDidPerformAction(_ commentTreeNode: CommentTreeNode, comment: Comment, action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?)
}

class CommentTreeNode: ASCellNode {
  let commentNode: CommentNode
  var repliesCommentNodes: [CommentNode]
  let viewRepliesDisclosureNode: DisclosureNode
  fileprivate var highlightNode: HighlightNode?
  
  var commentNodeThatNeedsHighlight: ASDisplayNode?
  
  fileprivate(set) var mode: DisplayMode = .normal
  
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
    repliesCommentNodes = []
    super.init()
    initializeNode()
  }
  
  func initialize(with mode: DisplayMode) {
    self.mode = mode
    refreshCommentNodeMode()
    refreshRepliesCommentNodes()
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
        for replyCommentNode in repliesCommentNodes {
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
    commentNode.imageURL = URL(string: comment?.penName?.avatarUrl ?? "")
    commentNode.fullName = comment?.penName?.name
    commentNode.message = comment?.body
    commentNode.setWitValue(witted: comment?.isWitted ?? false,
                            numberOfWits: comment?.counts?.wits)
    if let createDate = comment?.createdAt as Date? {
      commentNode.date = createDate
    }
    refreshRepliesCommentNodes()
    refreshCommentNodeMode()
    setNeedsLayout()
  }
  
  fileprivate func refreshCommentNodeMode() {
    commentNode.mode = (mode == .minimal) ? .minimal : (isReply ? .reply : .normal)
    setNeedsLayout()
  }
  
  fileprivate func refreshRepliesCommentNodes() {
    repliesCommentNodes.removeAll()
    switch mode {
    case .normal:
      if let repliesComments = comment?.replies?.prefix(configuration.maximumRepliesDisplayed) {
        for replyComment in repliesComments {
          let replyCommentNode = CommentNode()
          replyCommentNode.mode = .reply
          replyCommentNode.delegate = self
          replyCommentNode.imageURL = URL(string: replyComment.penName?.avatarUrl ?? "")
          replyCommentNode.fullName = replyComment.penName?.name
          replyCommentNode.message = replyComment.body
          replyCommentNode.setWitValue(witted: replyComment.isWitted,
                                       numberOfWits: replyComment.counts?.wits)
          if let createDate = replyComment.createdAt as Date? {
            replyCommentNode.date = createDate
          }
          repliesCommentNodes.append(replyCommentNode)
        }
      }
    default:
      return
    }
    setNeedsLayout()
  }
  
  func refreshDisclosureNodeText() {
    viewRepliesDisclosureNode.text = Strings.view_all_replies(number: comment?.counts?.children ?? 0)
    setNeedsLayout()
  }
  
  //MARK: APIs
  //==========
  var comment: Comment? {
    didSet {
      refreshCommentNode()
      refreshDisclosureNodeText()
    }
  }
  
  var hasReplies: Bool {
    return (comment?.counts?.children ?? 0) > 0
  }
  
  /// Additional replies are not displayed
  var hasAdditionalReplies: Bool {
    let repliesCount = comment?.counts?.children ?? 0
    return repliesCount > configuration.maximumRepliesDisplayed
  }
  
  var isReply: Bool {
    return !(comment?.parentId.isEmptyOrNil() ?? true)
  }
  
  //MARK: HELPERS
  //=============
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
    guard let comment = comment else {
      return
    }

    delegate?.commentTreeDidPerformAction(self, comment: comment, action: action, forSender: sender, didFinishAction: didFinishAction)
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
    guard let comment = comment else {
      return
    }
    delegate?.commentTreeDidTapViewReplies(self, comment: comment)
  }
}
