//
//  BookDetailsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsNode: ASDisplayNode {
  var book: Book?
  
  private var headerNode = BookDetailsHeaderNode()
  
  override init() {
    super.init()
    automaticallyManagesSubnodes = true
    applyTheme()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.width = ASDimensionMake(constrainedSize.max.width)
    let mainStack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0,
      justifyContent: .start, alignItems: .center, children: [headerNode])
    return mainStack
  }
  
  func initializeContent() {
    // Set header information
    headerNode.title = book.title
    headerNode.author = book.productDetails?.author
    headerNode.imageURL = URL(string: book.coverImageUrl ?? "")
  }
}

extension BookDetailsNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

