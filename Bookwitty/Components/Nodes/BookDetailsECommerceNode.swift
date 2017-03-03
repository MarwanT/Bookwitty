//
//  BookDetailsECommerceNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsECommerceNode: ASDisplayNode {
  fileprivate let pricesNode: BookDetailsPricesNode
  fileprivate let separatorNode: ASDisplayNode
  fileprivate let stockNode: BookDetailsStockNode
  
  var configuration = Configuration()
  
  override init() {
    pricesNode = BookDetailsPricesNode()
    stockNode = BookDetailsStockNode()
    separatorNode = ASDisplayNode()
    super.init()
  }
}

extension BookDetailsECommerceNode {
  struct Configuration {
    var separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    fileprivate var separatorHeight: CGFloat = 1
    fileprivate var separatorEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin() - 9, 0,
      ThemeManager.shared.currentTheme.generalExternalMargin() - 9, 0)
  }
}
