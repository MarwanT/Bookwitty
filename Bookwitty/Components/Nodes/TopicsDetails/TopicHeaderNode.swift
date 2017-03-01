//
//  TopicHeaderNode.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicHeaderNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  private var imageNode: ASNetworkImageNode

  override init() {
    imageNode = ASNetworkImageNode()
    super.init()
    addSubnode(imageNode)
    setupNode()
  }

  private func setupNode() {
    
  }
}
