//
//  BookDetailsECommerceNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol BookDetailsECommerceNodeDelegate: class {
  func eCommerceNodeDidTapOnBuyBook(node: BookDetailsECommerceNode)
  func eCommerceNodeDidTapOnShippingInformation(node: BookDetailsECommerceNode)
}

class BookDetailsECommerceNode: ASCellNode {
  fileprivate let pricesNode: BookDetailsPricesNode
  fileprivate let separatorNode: ASDisplayNode
  fileprivate let stockNode: BookDetailsStockNode
  
  weak var delegate: BookDetailsECommerceNodeDelegate? = nil
  
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
    
    stockNode.delegate = self
    
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    separatorNode.style.width = ASDimensionMake(constrainedSize.max.width)
    
    let separatorInsetsSpecs = ASInsetLayoutSpec(insets: configuration.separatorEdgeInsets, child: separatorNode)
    
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [pricesNode, separatorInsetsSpecs, stockNode])
    let externalInsets = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets, child: verticalStackSpec)
    return externalInsets
  }
  
  func set(supplierInformation: SupplierInformation?) {
    pricesNode.set(supplierInformation: supplierInformation)
    stockNode.set(supplierInformation: supplierInformation)
    setNeedsLayout()
  }
}

// MARK: -
extension BookDetailsECommerceNode: BookDetailsStockNodeDelegate {
  func stockNodeDidTapOnShippingInformation(node: BookDetailsStockNode) {
    delegate?.eCommerceNodeDidTapOnShippingInformation(node: self)
  }
  
  func stockNodeDidTapOnBuyBook(node: BookDetailsStockNode) {
    delegate?.eCommerceNodeDidTapOnBuyBook(node: self)
  }
}

// MARK: - Declarations
extension BookDetailsECommerceNode {
  struct Configuration {
    var externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(), bottom: 0,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    fileprivate var separatorHeight: CGFloat = 1
    fileprivate var separatorEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin() - 9, 0,
      ThemeManager.shared.currentTheme.generalExternalMargin() - 9, 0)
  }
}
