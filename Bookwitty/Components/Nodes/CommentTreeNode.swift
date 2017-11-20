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
  
  fileprivate(set) var mode: DisplayMode = .normal
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
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
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    UIView.animate(withDuration: 0.60, animations: {
      self.backgroundColor = self.configuration.defaultColor
    }) { (success) in
      context.completeTransition(true)
    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var elements: [ASLayoutElement] = []
    elements.append(commentNode)
    
    if hasReplies && !configuration.shouldHideViewRepliesDisclosureNode {
      let children: [ASLayoutElement] = [separator(), viewRepliesDisclosureNode, separator()]
      let disclosureStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: children)
      let disclosureNodeInsetsSpec = ASInsetLayoutSpec(insets: configuration.disclosureInsets, child: disclosureStackSpec)
      elements.append(disclosureNodeInsetsSpec)
      commentNode.configuration.hideBottomActionBarSeparator = true
    } else {
      commentNode.configuration.hideBottomActionBarSeparator = false
    }
    
    let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: elements)
    var insets = configuration.externalInsets
    if configuration.leftIndentToParentNode {
      insets.left += configuration.indentationMargin
    }
    let externalInsetsSpec = ASInsetLayoutSpec(insets: insets, child: verticalStack)
    return externalInsetsSpec
  }
  
  override func layoutDidFinish() {
    super.layoutDidFinish()
    unHighlightNode()
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
      if let repliesComments = comment?.replies {
        for replyComment in repliesComments {
          let replyCommentNode = CommentNode()
          replyCommentNode.mode = .reply
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
  
  var isReply: Bool {
    return !(comment?.parentId.isEmptyOrNil() ?? true)
  }
  
  //MARK: HELPERS
  //=============
  fileprivate func highlightNode() {
    backgroundColor = configuration.highlightColor
  }
  
  fileprivate func unHighlightNode() {
    if backgroundColor != configuration.defaultColor {
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
  }
  
  fileprivate func separator() -> ASDisplayNode {
    let separator = ASDisplayNode()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1)
    return separator
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
    fileprivate let indentationMargin = CommentNode.Configuration().indentationMargin
    let disclosureInsets: UIEdgeInsets
    var shouldHideViewRepliesDisclosureNode: Bool = true
    var leftIndentToParentNode: Bool = false
    var externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin() / 2,
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var highlightColor = ThemeManager.shared.currentTheme.colorNumber5()
    var defaultColor = UIColor.white
    
    init() {
      disclosureInsets = UIEdgeInsets(top: 0, left: indentationMargin, bottom: 0, right: 0)
    }
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
  
  func commentNodeShouldUpdateLayout(_ node: CommentNode) {
    highlightNode()
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
