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

  fileprivate var normal: [Category] = [.latest(index: 0), .relatedBooks(index: 1), .followers(index: 2) ]
  fileprivate var book: [Category] = [.latest(index: 0), .relatedBooks(index: 1), .editions(index: 2), .followers(index: 3)]

  fileprivate lazy var mode: Mode = .normal(categories: self.normal)

  fileprivate let viewModel = TopicViewModel()

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

  func initialize(with topic: Topic?) {
    viewModel.initialize(with: topic)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
  }

  private func initializeComponents() {
    let segments: [String] = self.mode.categories.map({ $0.name })
    segmentedNode.initialize(with: segments)

    segmentedNode.selectedSegmentChanged = segmentedNode(segmentedControlNode:didSelectSegmentIndex:)

    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }

  fileprivate func fillHeaderNode() {
    let values = viewModel.valuesForTopic()

    headerNode.topicTitle = values.title
    headerNode.imageUrl = values.coverImageUrl

    headerNode.setTopicStatistics(numberOfFollowers: values.stats.followers, numberOfPosts: values.stats.posts)
    headerNode.setContributorsValues(numberOfContributors: values.contributors.count, imageUrls: values.contributors.imageUrls)
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {
    //TODO: Add the segment selected index logic
  }
}

//MARK: - Mode Helpers
extension TopicViewController {
  fileprivate enum Mode {
    case normal(categories: [Category])
    case book(categories: [Category])

    var categories: [Category] {
      switch self {
      case .normal(let categories):
        return categories
      case .book(let categories):
        return categories
      }
    }
  }

  fileprivate enum Category {
    case latest(index: Int)
    case relatedBooks(index: Int)
    case editions(index: Int)
    case followers(index: Int)
    case none

    //TODO: Should be localized
    var name: String {
      switch self {
      case .latest:
        return "Latest"
      case .relatedBooks:
        return "Related Books"
      case .editions:
        return "Editions"
      case .followers:
        return "Followers"
      case .none:
        return ""
      }
    }

    var index: Int {
      switch self {
      case .latest(let index):
        return index
      case .relatedBooks(let index):
        return index
      case .editions(let index):
        return index
      case .followers(let index):
        return index
      case .none:
        return NSNotFound
      }
    }
  }

  fileprivate func category(withIndex index: Int) -> Category {
    guard let category = self.mode.categories.filter({ $0.index == index }).first else {
      return .none
    }

    return category
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
