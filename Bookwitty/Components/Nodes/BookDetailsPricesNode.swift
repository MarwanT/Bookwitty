//
//  BookDetailsPricesNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsPricesNode: ASDisplayNode {
  fileprivate let priceTextNode: ASTextNode
  fileprivate let userPriceTextNode: ASTextNode
  fileprivate let listPriceTextNode: ASTextNode
  fileprivate let savingTextNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    priceTextNode = ASTextNode()
    userPriceTextNode = ASTextNode()
    listPriceTextNode = ASTextNode()
    savingTextNode = ASTextNode()
    super.init()
  }
}

extension BookDetailsPricesNode {
  struct Configuration {
    let priceTextColor = ThemeManager.shared.currentTheme.defaultECommerceColor()
    let userPriceTextColor = ThemeManager.shared.currentTheme.colorNumber15()
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var textEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
    fileprivate var savingPricesEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin() - 9, 0, 0, 0)
  }
}
