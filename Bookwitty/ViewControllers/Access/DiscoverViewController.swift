//
//  DiscoverViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class DiscoverViewController: ASViewController<ASCollectionNode> {
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let pullToRefresher = UIRefreshControl()

  var collectionView: ASCollectionView?

  let viewModel = DiscoverViewModel()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin/2, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init(node: collectionNode)

    collectionNode.onDidLoad { [weak self] (collectionNode) in
      guard let strongSelf = self,
        let asCollectionView = collectionNode.view as? ASCollectionView else {
          return
      }
      strongSelf.collectionView = asCollectionView
      strongSelf.collectionView?.addSubview(strongSelf.pullToRefresher)
      strongSelf.collectionView?.alwaysBounceVertical = true
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionNode.delegate = self
    collectionNode.dataSource = self
    applyTheme()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }

  func loadData() {
    pullToRefresher.beginRefreshing()
    viewModel.loadDiscoverData { [weak self] (success) in
      guard let strongSelf = self else { return }
      strongSelf.pullToRefresher.endRefreshing()
      strongSelf.collectionNode.reloadData()
    }
  }
}

// MARK: - Themeable
extension DiscoverViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    pullToRefresher.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
  }
}

extension DiscoverViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSection()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row

    return {
      let baseCardNode = self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
      return baseCardNode
    }
  }
}

extension DiscoverViewController: ASCollectionDelegate {
  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage()
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection()

    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection()

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        let updatedIndexPathRange: [IndexPath]  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: 0)
        })
        strongSelf.loadItemsWithIndex(updatedRange: updatedIndexPathRange)
      }

      // Properly finish the batch fetch
      context.completeBatchFetching(true)
    }
  }

  /**
   * Note: loadItemsWithIndex will always run on the main thread
   */
  func loadItemsWithIndex(updatedRange: [IndexPath]) {
    if Thread.isMainThread {
      collectionNode.insertItems(at: updatedRange)
    } else {
      DispatchQueue.main.async {
        [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.collectionNode.insertItems(at: updatedRange)
      }
    }
  }
}
