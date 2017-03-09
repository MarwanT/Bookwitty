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
  
  override func didLoad() {
    super.didLoad()
    view.tableFooterView = UIView(frame: CGRect.zero)
    view.separatorInset = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
  }
  
  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return tableViewData.count > 0 ? 3 : 0 // Header + Data + Footer
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: // Header
      return 1
    case 1: // Data
      return tableViewData.count
    default:
      return 0
    }
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    switch indexPath.section {
    case 0: // Header
      return {
        let cell = SectionTitleHeaderNode()
        cell.setTitle(
          title: Strings.book_details(),
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber8(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber7())
        cell.separatorInset.left = 1000
        return cell
      }
    case 1: // Data
      let data = tableViewData[indexPath.row]
      return {
        let cell = DetailsInfoCellNode()
        cell.key = data.key
        cell.value = data.value
        return cell
      }
    default:
      return { return ASCellNode() }
    }
  }
  
  func tableNode(_ tableNode: ASTableNode, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    tableNode.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.section {
    case 0: // Header
      return nil
    case 1: // Data
      return indexPath
    default:
      return nil
    }
  }
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Helpers
extension BookDetailsInformationNode {
  fileprivate func  refactorProductDetailsForTableData() {
    tableViewData.removeAll()
    if let associatedValues = productDetails?.associatedKeyValues() {
      tableViewData = associatedValues
    }
  }
  
  fileprivate func reloadNode() {
    reloadData()
  }
}
