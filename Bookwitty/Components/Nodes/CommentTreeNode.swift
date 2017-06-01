//
//  CommentTreeNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentTreeNode: ASCellNode {
  let commentNode: CommentNode
  let viewRepliesDisclosureNode: DisclosureNode
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init() {
    commentNode = CommentNode()
    viewRepliesDisclosureNode = DisclosureNode()
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    viewRepliesDisclosureNode.text = Strings.view_all()
    
    var disclosureNodeConfiguration = DisclosureNode.Configuration()
    disclosureNodeConfiguration.style = .highlighted
    disclosureNodeConfiguration.nodeEdgeInsets.left = 0
    disclosureNodeConfiguration.imageNodeInsets.right = 0
    viewRepliesDisclosureNode.configuration = disclosureNodeConfiguration
  }
  
  var comment: Comment? {
    didSet {
      refreshCommentNode()
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
    commentNode.configuration.showBottomActionBarSeparator = hasReplies ? false : true
    setNeedsLayout()
  }
  
  var hasReplies: Bool {
    return (comment?.counts?.children ?? 0) > 0
  }
  
  var isReply: Bool {
    return !(comment?.parentId.isEmptyOrNil() ?? true)
  }
}

extension CommentTreeNode {
  struct Configuration {
    var shouldDisplayViewRepliesDisclosureNode: Bool = true
    var externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin() / 2,
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
