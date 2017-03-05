//
//  OnBoardingItemHeaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingItemHeaderNode: ASDisplayNode {
  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  static let nodeHeight: CGFloat = 45.0

  private let titleTextNode: ASTextNode
  private let rotatingImageNode: RotatingImageNode
  private let separator: ASDisplayNode

  override init() {
    rotatingImageNode = RotatingImageNode(image: #imageLiteral(resourceName: "downArrow"), size: CGSize(width: 45.0, height: 45.0), direction: .right)
    titleTextNode = ASTextNode()
    separator = ASDisplayNode()

    super.init()
    automaticallyManagesSubnodes = true
  }
}
