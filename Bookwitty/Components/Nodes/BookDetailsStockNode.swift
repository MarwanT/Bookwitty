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
    initializeComponents()
    applyTheme()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    availabilityTextNode.isLayerBacked = true
    
    shippingInformation = Strings.free_shipping_internationally()
    buyButtonText = Strings.buy_this_book()
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
  
  enum ProductAvailability {
    case inStock
    case outOfStock
    
    var string: String {
      switch self {
      case .inStock:
        return Strings.in_stock()
      case .outOfStock:
        return Strings.out_of_stock()
      }
    }
    
    var color: UIColor {
      switch self {
      case .inStock:
        return ThemeManager.shared.currentTheme.colorNumber21()
      case .outOfStock:
        return ThemeManager.shared.currentTheme.defaultErrorColor()
      }
    }
  }
}

extension BookDetailsStockNode: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleECommercePrimaryButton(button: buyThisBookButtonNode)
  }
}
