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
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
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
    commentNode.setWitValue(witted: comment?.isWitted ?? false, wits: comment?.counts?.wits ?? 0)
    commentNode.setDimValue(dimmed: comment?.isDimmed ?? false, dims: comment?.counts?.dims ?? 0)
    if let createDate = comment?.createdAt as Date? {
      commentNode.date = createDate
    }
    commentNode.mode = isReply ? .secondary : .primary
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
    var elements = [ASLayoutElement]()
    elements.append(commentNode)
    
    if hasReplies && !configuration.shouldHideViewRepliesDisclosureNode {
      elements.append(contentsOf: [separator(), viewRepliesDisclosureNode, separator()])
      commentNode.configuration.hideBottomActionBarSeparator = true
    } else {
      commentNode.configuration.hideBottomActionBarSeparator = false
    }
    
    let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: elements)
    let externalInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalInsets, child: verticalStack)
    return externalInsetsSpec
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
    var shouldHideViewRepliesDisclosureNode: Bool = true
    var externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin() / 2,
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
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
