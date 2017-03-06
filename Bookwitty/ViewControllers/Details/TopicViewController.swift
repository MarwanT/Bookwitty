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
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}

extension TopicViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.zero : CGSize(width: collectionView.frame.size.width, height: segmentedNodeHeight)
  }
}

extension TopicViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 2
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? 1 : 20
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    if indexPath.section == 0 {
      return {
        return self.headerNode
      }
    }

    return {
      return BaseCardPostNode()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    guard indexPath.section == 1 else {
      return ASCellNode()
    }

    switch kind {
    case UICollectionElementKindSectionHeader:
      return self.segmentedNode
    default:
      return ASCellNode()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {

  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
