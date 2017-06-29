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

  }
}
