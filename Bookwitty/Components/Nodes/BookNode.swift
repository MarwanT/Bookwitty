//
//  BookNode.swift
//  Bookwitty
//
//  Created by charles on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BookNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 100.0, height: 125.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var formatNode: ASTextNode
  private var priceNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    formatNode = ASTextNode()
    priceNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(authorNode)
    addSubnode(formatNode)
    addSubnode(priceNode)
    setupNode()
  }

  private func setupNode() {
    
  }
}
