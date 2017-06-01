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
