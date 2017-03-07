//
//  BookDetailsInformationNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsInformationNode: ASTableNode, ASTableDelegate, ASTableDataSource {
  var productDetails: ProductDetails? = nil {
    didSet {
    }
  }
  
  fileprivate var tableViewData = [(key: String, value: String)]() {
    didSet {
    }
  }
  
}
