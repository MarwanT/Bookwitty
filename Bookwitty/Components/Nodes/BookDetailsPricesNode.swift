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
  
  override init() {
    priceTextNode = ASTextNode()
    userPriceTextNode = ASTextNode()
    listPriceTextNode = ASTextNode()
    savingTextNode = ASTextNode()
    super.init()
  }
}
