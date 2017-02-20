//
//  PenNameSelectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PenNameSelectionNode: ASCellNode {
  fileprivate static let cellHeight: CGFloat = 45.0
  fileprivate let maxNumberOfCells: Int = 5
  fileprivate let separatorHeight: CGFloat = 1.0
  fileprivate let collapsedHeightDimension: ASDimension = ASDimension(unit: ASDimensionUnit.points, value: PenNameSelectionNode.cellHeight)
  fileprivate var expandedHeightDimension: ASDimension {
    get {
      let itemHeight = collapsedHeightDimension.value
      let actualNumberOfCells = (maxNumberOfCells > data.count) ? data.count : maxNumberOfCells
      let expandedHeight = itemHeight + (itemHeight * CGFloat(actualNumberOfCells))

      return ASDimension(unit: ASDimensionUnit.points, value: expandedHeight)
    }
  }
  fileprivate var expandedCollectionHeight: CGFloat {
    get {
      return expandedHeightDimension.value - PenNameSelectionNode.cellHeight
    }
  }

  fileprivate let header: PenNameDisplayNode
  fileprivate let lastSeparatorNode: ASDisplayNode
  fileprivate let collectionNode: ASCollectionNode

  private let flowLayout: UICollectionViewFlowLayout

  var expand: Bool = true
  var data: [String] = ["Shafic Hariri"]
  var selectedIndexPath: IndexPath? = nil

  override init() {
    super.init()
  }
}

