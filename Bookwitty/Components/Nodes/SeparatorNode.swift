//
//  SeparatorNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class SeparatorNode: ASDisplayNode {
  private override init() {
    super.init()
  }

  convenience init(color: UIColor = ThemeManager.shared.currentTheme.defaultSeparatorColor(), width: CGFloat? = nil, height: CGFloat = 1.0) {
    self.init()
    backgroundColor = color
    style.flexGrow = 1
    style.flexShrink = 1
    style.height = ASDimensionMake(height)
    if let width = width {
      style.width = ASDimensionMake(width)
    }
  }
}
