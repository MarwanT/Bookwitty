//
//  BookDetailsStockNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol BookDetailsStockNodeDelegate: class {
  func stockNodeDidTapOnBuyBook(node: BookDetailsStockNode)
  func stockNodeDidTapOnShippingInformation(node: BookDetailsStockNode)
}

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
    
    shippingInformationTextNode.addTarget(self, action: #selector(self.shippingInformationTouchUpInside(_:)), forControlEvents: .touchUpInside)
    buyThisBookButtonNode.addTarget(self, action: #selector(self.buyThisBookTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let availabilityInsetsSpec = ASInsetLayoutSpec(insets: configuration.textEdgeInsets, child: availabilityTextNode)
    let shippingInsetsSpec = ASInsetLayoutSpec(insets: configuration.textEdgeInsets, child: shippingInformationTextNode)
    let buyButtonInsetsSpec = ASInsetLayoutSpec(insets: configuration.buyButtonEdgeInsets, child: buyThisBookButtonNode)
    
    var verticalSpecChildren: [ASLayoutElement] = [availabilityInsetsSpec]
    if availability == .inStock {
      verticalSpecChildren.append(shippingInsetsSpec)
      verticalSpecChildren.append(buyButtonInsetsSpec)
    }
    
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: verticalSpecChildren)
    return verticalStackSpec
  }
  
  func set(supplierInformation: SupplierInformation?) {
    guard let quantity = supplierInformation?.quantity else {
      return
    }
    availability = quantity > 0 ? .inStock : .outOfStock
  }
  
  
  // MARK: Subnodes Values APIs
  private var availability: ProductAvailability? {
    didSet {
      availabilityTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: (availability ?? .outOfStock).string, color: (availability ?? .outOfStock).color).attributedString
      setNeedsLayout()
    }
  }
  
  private var shippingInformation: String? {
    didSet {
      shippingInformationTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: "\(shippingInformation ?? "")*", color: configuration.defaultTextColor, underlineStyle: NSUnderlineStyle.styleSingle).attributedString
      setNeedsLayout()
    }
  }
  
  private var buyButtonText: String? {
    didSet {
      buyThisBookButtonNode.setTitle(buyButtonText ?? "", with: FontDynamicType.subheadline.font, with: configuration.buyButtonTextColor, for: ASControlState(rawValue: 0))
      setNeedsLayout()
    }
  }
  
  // MARK: Actions
  func shippingInformationTouchUpInside(_ sender: Any?) {
    print("Did Tap Shipping Information")
  }
  
  func buyThisBookTouchUpInside(_ sender: Any?) {
    print("Buy This Book")
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
