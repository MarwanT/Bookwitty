//
//  OnBoardingCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingCellNode: ASCellNode {
  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing: CGFloat = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let collapsedCellHeight: CGFloat = 45.0


  let headerNode: OnBoardingItemHeaderNode
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  override init() {
    headerNode = OnBoardingItemHeaderNode()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 45.0)

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init()

    automaticallyManagesSubnodes = true

    collectionNode.delegate = self
    collectionNode.dataSource = self
    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0

    showAll = true

    backgroundColor = UIColor.bwNero
  }

  override func didLoad() {
    super.didLoad()
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
  }
  
}
