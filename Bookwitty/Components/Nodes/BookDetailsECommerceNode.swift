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
    initializeComponents()
  }
  
  private func initializeComponents() {
    automaticallyManagesSubnodes = true
    separatorNode.isLayerBacked = true
    separatorNode.backgroundColor = configuration.separatorColor
    separatorNode.style.height = ASDimensionMake(configuration.separatorHeight)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    separatorNode.style.width = ASDimensionMake(constrainedSize.max.width)
    
    let separatorInsetsSpecs = ASInsetLayoutSpec(insets: configuration.separatorEdgeInsets, child: separatorNode)
    
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [pricesNode, separatorInsetsSpecs, stockNode])
    return verticalStackSpec
  }
  
  func set(supplierInformation: SupplierInformation?) {
    pricesNode.set(supplierInformation: supplierInformation)
    stockNode.set(supplierInformation: supplierInformation)
    setNeedsLayout()
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
