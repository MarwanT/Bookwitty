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
  }
}
