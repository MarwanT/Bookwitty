//
//  OnBoardingControllerNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingControllerNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let headerHeight: CGFloat = 45.0

  let titleTextNode: ASTextNode
  let separatorNode: ASDisplayNode
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  override init() {
    titleTextNode = ASTextNode()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    separatorNode = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
  }
}

