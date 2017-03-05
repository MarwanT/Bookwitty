//
//  OnBoardingCellSectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingCellSectionNode: ASCellNode {
  static let nodeHeight: CGFloat = 45.0

  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let titleTextNode: ASTextNode
  fileprivate let separator: ASDisplayNode


  override init() {
    titleTextNode = ASTextNode()
    separator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
  }
}
