//
//  OnBoardingInternalCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingInternalCellNode: ASCellNode {
  static let cellHeight: CGFloat = 115.0

  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  let titleTextNode: ASTextNode
  let shortDescriptionTextNode: ASTextNode
  let selectionButtonNode: ASButtonNode
  let imageNode: ASNetworkImageNode
  let separator: ASDisplayNode


  override init() {
    titleTextNode = ASTextNode()
    shortDescriptionTextNode =  ASTextNode()
    selectionButtonNode =  ASButtonNode()
    imageNode =  ASNetworkImageNode()
    separator = ASDisplayNode()
    super.init()
    initializeNode()
  }

  func initializeNode() {
    automaticallyManagesSubnodes = true

    shortDescriptionTextNode.maximumNumberOfLines = 3
    titleTextNode.maximumNumberOfLines = 1

    selectionButtonNode.backgroundColor = UIColor.bwRuby
    selectionButtonNode.style.preferredSize = CGSize(width: 36.0, height: 36.0)
    imageNode.style.preferredSize = CGSize(width: 45.0, height: 45.0)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    separator.style.height = ASDimensionMake(1.0)
    separator.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: OnBoardingInternalCellNode.cellHeight)
  }
}
