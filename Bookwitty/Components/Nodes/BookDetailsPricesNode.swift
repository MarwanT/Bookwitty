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
    initializeComponents()
  }
  
  private func initializeComponents() {
    automaticallyManagesSubnodes = true
    priceTextNode.isLayerBacked = true
    userPriceTextNode.isLayerBacked = true
    listPriceTextNode.isLayerBacked = true
    savingTextNode.isLayerBacked = true
  }
  
  func set(supplierInformation: SupplierInformation?) {
    guard let supplierInformation = supplierInformation else {
      setNeedsLayout()
      return
    }
    
    // Set price
    self.price = supplierInformation.preferredPrice?.formattedValue
    
    // Set user price if available
    self.userPrice = supplierInformation.userPrice?.formattedValue
    
    // Set list prive and saving price if available
    if let listPrice = supplierInformation.listPrice,
      let price = supplierInformation.price,
      let listPriceValue = listPrice.value,
      let listPriceCurrency = listPrice.currency,
      let priceValue = price.value,
      let priceCurrency = price.currency,
      listPriceCurrency == priceCurrency {
      
      let savedValue = listPriceValue - priceValue
      if savedValue > 0 {
        let savedPrice = Price(currency: priceCurrency, value: savedValue)
        self.savingPrice = savedPrice.formattedValue
        self.listPrice = listPrice.formattedValue
      } else {
        self.savingPrice = nil
        self.listPrice = nil
      }
    } else {
      self.savingPrice = nil
      self.listPrice = nil
    }
    
    setNeedsLayout()
  }
  
  private var price: String? {
    didSet {
      priceTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .headline)
        .append(text: price ?? "", color: configuration.priceTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  private var userPrice: String? {
    didSet {
      userPriceTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: "(\((userPrice ?? "")))", color: configuration.userPriceTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  private var listPrice: String? {
    didSet {
      listPriceTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1).append(text: (Strings.list_price() + ": "), color: configuration.defaultTextColor).append(text: listPrice ?? "", color: configuration.defaultTextColor, strikeThroughStyle: NSUnderlineStyle.styleSingle).attributedString
      setNeedsLayout()
    }
  }
  
  private var savingPrice: String? {
    didSet {
      savingTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: (Strings.you_save() + ": " + (savingPrice ?? "")), color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
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
