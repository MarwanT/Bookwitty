//
//  BookDetailsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsNode: ASDisplayNode {
  var book: Book?
  
  override init() {
    super.init()
    applyTheme()
  }
}

extension BookDetailsNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

