//
//  DiscoverNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 5/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class DiscoverNode: ASDisplayNode {

  fileprivate let segmentedNodeHeight: CGFloat = 45.0
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()

  fileprivate let collectionNode: ASCollectionNode
  fileprivate let flowLayout: UICollectionViewFlowLayout
  fileprivate let segmentedNode: SegmentedControlNode
  
  override init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    segmentedNode = SegmentedControlNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  func setupNode() {
    //Setup elements dimensions
    segmentedNode.style.preferredSize = CGSize(width: collectionNode.style.maxWidth.value, height: segmentedNodeHeight)
    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0
    //TODO: Node setup
  }
}

// MARK: - Layout Specs
extension DiscoverNode {
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let nodes: [ASLayoutElement] = [segmentedNode, collectionNode]
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0,
                                              justifyContent: .start,
                                              alignItems: .stretch,
                                              children: nodes)
    return verticalStackSpec
  }
}
