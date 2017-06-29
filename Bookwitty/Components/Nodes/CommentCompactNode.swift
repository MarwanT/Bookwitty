//
//  CommentCompactNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DTCoreText

class CommentCompactNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let messageNode: DTAttributedLabelNode

  override init() {
    imageNode = ASNetworkImageNode()
    messageNode = DTAttributedLabelNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true

    imageNode.style.preferredSize = CGSize(width: 30.0, height: 30.0)
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder

    messageNode.style.flexGrow = 1.0
    messageNode.style.flexShrink = 1.0

    self.style.preferredSize = CGSize(width: 45.0, height: 45.0)

    messageNode.maxNumberOfLines = 3
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageNodeInsetSpec = ASInsetLayoutSpec(insets: imageInset, child: imageNode)
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .center, children: [imageNodeInsetSpec, messageNode])
    return horizontalSpec
  }

  var imageInset: UIEdgeInsets {
    return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
  }
}
