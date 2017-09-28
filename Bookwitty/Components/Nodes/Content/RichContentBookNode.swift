//
//  RichContentBookNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/28.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RichContentBookNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 60.0, height: 90.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var addButton: ASButtonNode
  private var separatorNode: ASDisplayNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    addButton = ASButtonNode()
    separatorNode = ASDisplayNode()
    super.init()
  }
}
