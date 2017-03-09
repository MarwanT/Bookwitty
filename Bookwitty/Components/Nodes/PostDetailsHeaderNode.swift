//
//  PostDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PostDetailsHeaderNode: ASCellNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASTextNode
  fileprivate let profileBarNode: ASDisplayNode
  fileprivate let actionBarNode: CardActionBarNode
  fileprivate let separator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode

  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASTextNode()
    profileBarNode = ASDisplayNode()
    actionBarNode = CardActionBarNode()
    separator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  func initializeNode() {
    //Separator Styling
    //Post Iamge
    //Post Title
    //Profile Bar
    //Action Bar
  }
}
