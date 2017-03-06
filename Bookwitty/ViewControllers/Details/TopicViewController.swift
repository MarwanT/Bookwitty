//
//  TopicViewController.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicViewController: ASViewController<ASCollectionNode> {

  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let segmentedNodeHeight: CGFloat = 45.0

  fileprivate let collectionNode: ASCollectionNode

  fileprivate var headerNode: TopicHeaderNode
  fileprivate var segmentedNode: SegmentedControlNode
  fileprivate var flowLayout: UICollectionViewFlowLayout

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    headerNode = TopicHeaderNode()
    segmentedNode = SegmentedControlNode()

    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
  }

  private func initializeComponents() {
    //TODO: Should be localized and mapped to an enum
    segmentedNode.initialize(with: ["Latest", "Related Books", "Followers"])
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}
