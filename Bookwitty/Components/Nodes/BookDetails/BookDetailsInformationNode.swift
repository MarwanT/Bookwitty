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
  
  
  override init() {
    super.init()
    delegate = self
    dataSource = self
  }
  
  override func onDidLoad(_ body: @escaping ASDisplayNodeDidLoadBlock) {
    super.onDidLoad(body)
    view.tableFooterView = UIView(frame: CGRect.zero)
  }
  
  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return tableViewData.count > 0 ? 1 : 0
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return tableViewData.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    // TODO: Get info
    let data = tableViewData[indexPath.row]
    
    return {
      let cell = DetailsInfoCellNode()
      cell.key = data.key
      cell.value = data.value
      return cell
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
