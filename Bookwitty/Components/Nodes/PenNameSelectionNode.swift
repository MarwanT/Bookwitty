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
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    header = PenNameDisplayNode(withCellHeight: PenNameSelectionNode.cellHeight)
    lastSeparatorNode = ASDisplayNode()
    super.init()
    setupNode()
  }

  func setupNode() {
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    automaticallyManagesSubnodes = true

    header.penNameSummary = "Your feed (Shafic Hariri)"

    lastSeparatorNode.style.preferredSize = CGSize(width: style.maxWidth.value, height: separatorHeight)
    lastSeparatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    collectionNode.style.preferredSize = CGSize(width: style.maxWidth.value, height: expandedCollectionHeight)
    let extraSeparator = (data.count == 0) ? 0.0 : separatorHeight
    style.height = ASDimensionMake(expandedHeightDimension.value + extraSeparator)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//    Commented: Y Transition animation
//    separatorNode.style.width = ASDimensionMake(constrainedSize.max.width)
//    collectionNode.style.width = ASDimensionMake(constrainedSize.max.width)
//    header.style.layoutPosition = CGPoint.init(x: 0, y: 0)
//    separatorNode.style.layoutPosition = CGPoint.init(x: 0, y: 45.0)
//    collectionNode.style.layoutPosition = CGPoint.init(x: 0, y: addAll ? 46.0 : -(CGFloat(self.data.count)*45.0))
//    let nodes: [ASLayoutElement] = addAll ? [collectionNode, separatorNode, header] : [collectionNode, separatorNode, header]
//    let abosoluteLayout = ASAbsoluteLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.sizeToFit, children: nodes)
//    return abosoluteLayout

    let nodes: [ASLayoutElement] = expand ? [header, collectionNode, lastSeparatorNode] : [header] //
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0,
                                              justifyContent: .start,
                                              alignItems: .stretch,
                                              children: nodes)
    return verticalStackSpec
  }
}

