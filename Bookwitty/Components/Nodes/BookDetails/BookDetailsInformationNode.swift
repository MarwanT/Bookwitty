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
      refactorProductDetailsForTableData()
    }
  }
  
  fileprivate var tableViewData = [(key: String, value: String)]() {
    didSet {
      reloadNode()
    }
  }
  
}

// MARK: - Helpers
extension BookDetailsInformationNode {
  fileprivate func  refactorProductDetailsForTableData() {
    // TODO: apply logic
    tableViewData.removeAll()
    tableViewData = [
      ("Paper back", "224 pages"),
      ("Publisher", "Bloomsberry Press (Aug 2013)"),
      ("Language", "English"),
      ("ISBN-10", "1408834960"),
      ("ISBN-13", "978-1408834960"),
      ("Dimensions", "13 x 1.5 x 19.7 cm"),
      ("Shipping Weight", "159g")
    ]
  }
  
  fileprivate func reloadNode() {
    reloadData()
  }
}
