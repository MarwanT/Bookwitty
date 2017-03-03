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
  
  override init() {
    availabilityTextNode = ASTextNode()
    shippingInformationTextNode = ASTextNode()
    buyThisBookButtonNode = ASButtonNode()
    super.init()
  }
}

