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
  let viewRepliesDisclosureNode: DisclosureNode
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  weak var delegate: CommentTreeNodeDelegate?
  
  override init() {
    commentNode = CommentNode()
    viewRepliesDisclosureNode = DisclosureNode()
    super.init()
    setupNode()
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    UIView.animate(withDuration: 0.60, animations: {
      self.backgroundColor = self.configuration.defaultColor
    }) { (success) in
      context.completeTransition(true)
    }
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    commentNode.delegate = self
    
    var disclosureNodeConfiguration = DisclosureNode.Configuration()
    disclosureNodeConfiguration.style = .highlighted
    disclosureNodeConfiguration.nodeEdgeInsets.left = 0
    disclosureNodeConfiguration.imageNodeInsets.right = 0
    viewRepliesDisclosureNode.configuration = disclosureNodeConfiguration
    viewRepliesDisclosureNode.delegate = self
  }
  
  var comment: Comment? {
    didSet {
      refreshCommentNode()
      refreshDisclosureNodeText()
    }
  }
  
  func refreshCommentNode() {
    commentNode.imageURL = URL(string: comment?.penName?.avatarUrl ?? "")
    commentNode.fullName = comment?.penName?.name
    commentNode.message = comment?.body
    commentNode.setWitValue(witted: comment?.isWitted ?? false)
    if let createDate = comment?.createdAt as Date? {
      commentNode.date = createDate
    }
    // TODO: add the minimal case
    commentNode.mode = isReply ? .reply : .normal
    setNeedsLayout()
  }
  
  func refreshDisclosureNodeText() {
    viewRepliesDisclosureNode.text = Strings.view_all_replies(number: comment?.counts?.children ?? 0)
    setNeedsLayout()
  }
  
  var hasReplies: Bool {
    return (comment?.counts?.children ?? 0) > 0
  }
  
  var isReply: Bool {
    return !(comment?.parentId.isEmptyOrNil() ?? true)
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
  
  private func separator() -> ASDisplayNode {
    let separator = ASDisplayNode()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1)
    return separator
  }
}

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
  
  func highlightNode() {
    backgroundColor = configuration.highlightColor
  }
  
  func unHighlightNode() {
    if backgroundColor != configuration.defaultColor {
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
  }
}

// MARK: - Disclosure node delegate
extension CommentTreeNode: DisclosureNodeDelegate {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool) {
    guard let comment = comment else {
      return
    }
    delegate?.commentTreeDidTapViewReplies(self, comment: comment)
  }
}
