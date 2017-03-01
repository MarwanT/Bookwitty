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
  let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let pullToRefresher = UIRefreshControl()
  let loaderNode: LoaderNode

  var collectionView: ASCollectionView?

  let viewModel = DiscoverViewModel()
  
  var isLoadingMore: Bool = false {
    didSet {
      let bottomMargin: CGFloat = isLoadingMore ? -(externalMargin/2) : -(LoaderNode.nodeHeight - externalMargin/2)
      flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomMargin, right: 0)
      loaderNode.updateLoaderVisibility(show: isLoadingMore)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin/2, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    flowLayout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: LoaderNode.nodeHeight)
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    
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
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionFooter)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Strings.discover()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.loadData), for: .valueChanged)

    applyTheme()

    if UserManager.shared.isSignedIn {
      loadData()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateRefreshControllerIfNeeded()
  }

  /*
   When the refresh controller is still refreshing, and we navigate away and
   back to this view controller, the activity indicator stops animating.
   The is a turn around to re animate it if needed
   */
  private func animateRefreshControllerIfNeeded() {
    guard let collectionView = collectionView else {
      return
    }

    if self.pullToRefresher.isRefreshing == true {
      let offset = collectionView.contentOffset

      self.pullToRefresher.endRefreshing()
      self.pullToRefresher.beginRefreshing()
      collectionView.contentOffset = offset
    }
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
      baseCardNode.delegate = self
      return baseCardNode
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    switch kind {
    case UICollectionElementKindSectionFooter: return loaderNode
    default: return ASCellNode()
    }
  }
}

extension DiscoverViewController: ASCollectionDelegate {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: LoaderNode.nodeHeight)
  }

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
    guard !isLoadingMore else {
      return
    }
    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection()
    
    DispatchQueue.main.async {
      self.isLoadingMore = true
    }
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
        strongSelf.loadItemsWithIndexOnMainThread() {
          collectionNode.insertItems(at: updatedIndexPathRange)
          strongSelf.isLoadingMore = false
        }
      }

      // Properly finish the batch fetch
      context.completeBatchFetching(true)
    }
  }

  /**
   * Note: loadItemsWithIndex will always run on the main thread
   */
  func loadItemsWithIndexOnMainThread(completionBlock: @escaping () -> ()) {
    if Thread.isMainThread {
      completionBlock()
    } else {
      DispatchQueue.main.async {
        completionBlock()
      }
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension DiscoverViewController: BaseCardPostNodeDelegate {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    guard let index = collectionNode.indexPath(for: card)?.item else {
      return
    }

    switch(action) {
    case .wit:
      viewModel.witContent(index: index) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(index: index) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: String = viewModel.sharingContent(index: index) {
        presentShareSheet(shareContent: sharingInfo)
      }
    default:
      //TODO: handle comment
      break
    }
  }
}
