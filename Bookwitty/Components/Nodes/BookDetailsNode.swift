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
    
    let mainStack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0,
      justifyContent: .start, alignItems: .center, children: [headerNode, formatNodeInsetSpec])
    return mainStack
  }
  
  func initializeContent() {
    // Set header information
    headerNode.title = book.title
    headerNode.author = book.productDetails?.author
    headerNode.imageURL = URL(string: book.coverImageUrl ?? "")
    
    // Set format Information
    formatNode.format = book.productDetails?.productFormat
  }
}

extension BookDetailsNode {
  struct Configuration {
    fileprivate let formatNodeEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.generalExternalMargin(),
      ThemeManager.shared.currentTheme.generalExternalMargin(),
      ThemeManager.shared.currentTheme.generalExternalMargin(),
      ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}

extension BookDetailsNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

