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
  
  override init() {
    pricesNode = BookDetailsPricesNode()
    stockNode = BookDetailsStockNode()
    separatorNode = ASDisplayNode()
    super.init()
  }
}

