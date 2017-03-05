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

    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 0.0)

    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    titleTextNode.style.maxHeight = ASDimensionMake(headerHeight)
    titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
      .append(text: "Following People and Topics is how you fill up your home feed with interesting reads.", color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString

    separatorNode.style.height = ASDimensionMake(1.0)
    separatorNode.backgroundColor  = ThemeManager.shared.currentTheme.colorNumber18()
    separatorNode.isLayerBacked = true
  }
}

