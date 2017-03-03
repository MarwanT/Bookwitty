//
//  BookDetailsStockNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsStockNode: ASDisplayNode {
  fileprivate let availabilityTextNode: ASTextNode
  fileprivate let shippingInformationTextNode: ASTextNode
  fileprivate let buyThisBookButtonNode: ASButtonNode
  
  var configuration = Configuration()
  
  override init() {
    availabilityTextNode = ASTextNode()
    shippingInformationTextNode = ASTextNode()
    buyThisBookButtonNode = ASButtonNode()
    super.init()
  }
}


extension BookDetailsStockNode {
  struct Configuration {
    var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var buyButtonTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    fileprivate var textEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
    fileprivate var buyButtonEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin(), 0, 0, 0)
  }
}

