//
//  BookDetailsFormatNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsFormatNode: ASControlNode {
  fileprivate let textNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    textNode = ASTextNode()
    super.init()
    applyTheme()
  }
}

extension BookDetailsFormatNode {
  struct Configuration {
    let textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var viewEdgeInset = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin())
  }
}

extension BookDetailsFormatNode: Themeable {
  func applyTheme() {
    borderWidth = 1.0
    borderColor = ThemeManager.shared.currentTheme.colorNumber18().cgColor
  }
}
