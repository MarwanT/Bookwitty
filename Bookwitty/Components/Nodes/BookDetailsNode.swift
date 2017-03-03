//
//  BookDetailsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsNode: ASDisplayNode {
  var book: Book! = nil {
    didSet {
      initializeContent()
      setNeedsLayout()
    }
  }
  
  private var headerNode = BookDetailsHeaderNode()
  private var formatNode = BookDetailsFormatNode()
  private var eCommerceNode = BookDetailsECommerceNode()
  
  var configuration = Configuration()
  
  override init() {
    super.init()
    automaticallyManagesSubnodes = true
    applyTheme()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.width = ASDimensionMake(constrainedSize.max.width)
    
    let formatNodeInsetSpec = ASInsetLayoutSpec(
      insets: configuration.formatNodeEdgeInsets, child: formatNode)
    let eCommerceNodeInsetSpec = ASInsetLayoutSpec(
      insets: configuration.eCommerceNodeEdgeInsets, child: eCommerceNode)
    
    var layoutElements = [ASLayoutElement]()
    layoutElements.append(headerNode)
    if book.productDetails?.productFormat != nil {
      layoutElements.append(formatNodeInsetSpec)
    }
    if book.supplierInformation != nil {
      layoutElements.append(eCommerceNodeInsetSpec)
    }
    
    let mainStack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0,
      justifyContent: .start, alignItems: .center, children: layoutElements)
    return mainStack
  }
  
  func initializeContent() {
    // Set header information
    headerNode.title = book.title
    headerNode.author = book.productDetails?.author
    headerNode.imageURL = URL(string: book.coverImageUrl ?? "")
    
    // Set format Information
    formatNode.format = book.productDetails?.productFormat
    
    // Set e-commerce Information
    eCommerceNode.set(supplierInformation: book.supplierInformation)
  }
}

extension BookDetailsNode {
  struct Configuration {
    fileprivate let formatNodeEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin(),
      ThemeManager.shared.currentTheme.generalExternalMargin(), 0,
      ThemeManager.shared.currentTheme.generalExternalMargin())
    fileprivate let eCommerceNodeEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin(),
      ThemeManager.shared.currentTheme.generalExternalMargin(), 0,
      ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}

extension BookDetailsNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

