//
//  PenNameFollowNode.swift
//  Bookwitty
//
//  Created by charles on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameFollowNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)

  private var imageNode: ASNetworkImageNode
  private var nameNode: ASTextNode
  private var biographyNode: ASTextNode
  private var actionButton: ASButtonNode

  override init() {
    imageNode = ASNetworkImageNode()
    nameNode = ASTextNode()
    biographyNode = ASTextNode()
    actionButton = ASButtonNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(nameNode)
    addSubnode(biographyNode)
    addSubnode(actionButton)
    setupNode()
  }

  private func setupNode() {

  }
}
