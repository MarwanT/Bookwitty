//
//  TagFeedViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TagFeedViewController: ASViewController<ASCollectionNode> {

  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let loaderNode: LoaderNode
  let refreshControllerer = UIRefreshControl()

  let viewModel = TagFeedViewModel()

  fileprivate var loadingStatus: LoadingStatus = .none
  fileprivate var shouldShowLoader: Bool {
    return (loadingStatus != .none && loadingStatus != .reloading)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    collectionNode.dataSource = self
    collectionNode.delegate = self

    title = viewModel.tag?.title

    collectionNode.view.addSubview(refreshControllerer)
    collectionNode.view.alwaysBounceVertical = true
    refreshControllerer.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)

    self.loadingStatus = .loading
    loadFeeds()
    setupNavigationBarButtons()
  }

  fileprivate func loadFeeds() {
    viewModel.loadFeeds { (success: Bool) in
      self.collectionNode.reloadData()

      self.loadingStatus = .none
      if self.refreshControllerer.isRefreshing {
        self.refreshControllerer.endRefreshing()
      }
    }
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    let title = Strings.follow()
    let rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonTouchUpInside(_:)))
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }

  func pullToRefresh() {
    guard refreshControllerer.isRefreshing else {
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }
    guard loadingStatus == .none else {
      refreshControllerer.endRefreshing()
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }

    self.loadingStatus = .reloading
    self.refreshControllerer.beginRefreshing()
    loadFeeds()
  }
}

// MARK: - Navigation Actions
extension TagFeedViewController {
  @objc
  fileprivate func rightBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    //TODO: Follow the tag
  }
}

// MARK: - Declarations
extension TagFeedViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case cards
    case activityIndicator

    static var numberOfSections: Int {
      return 2
    }
  }
}

//MARK: ASCollectionDataSource, ASCollectionDelegate implementation
extension TagFeedViewController: ASCollectionDataSource, ASCollectionDelegate {
  private func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = self.viewModel.resourceForIndex(index: index) else {
      return nil
    }

    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }


  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Section.numberOfSections
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case TagFeedViewController.Section.cards.rawValue:
      return self.viewModel.data.count
    case TagFeedViewController.Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let section = indexPath.section
    return {
      if section == Section.cards.rawValue {
        let baseCardNode = self.nodeForItem(atIndex: index) ?? BaseCardPostNode()

        if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
          !readingListCell.node.isImageCollectionLoaded {
          let max = readingListCell.node.maxNumberOfImages
          self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
            if let imageCollection = imageCollection, imageCollection.count > 0 {
              readingListCell.node.prepareImages(imageCount: imageCollection.count)
              readingListCell.node.loadImages(with: imageCollection)
            }
          })
        }

        return baseCardNode
      } else if section == Section.activityIndicator.rawValue {
        return self.loaderNode
      } else {
        return ASCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: shouldShowLoader)
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(index: indexPath.row), let commonResource =  resource as? ModelCommonProperties else {
          return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == Section.cards.rawValue else {
      return
    }

    //TODO: do action
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
    guard context.isFetching() else {
      return
    }
    guard loadingStatus == .none else {
      context.completeBatchFetching(true)
      return
    }
    context.beginBatchFetching()
    self.loadingStatus = .loadMore

    viewModel.loadNext { (success: Bool) in
      collectionNode.performBatchUpdates({ 
        collectionNode.reloadSections(IndexSet(integer: Section.cards.rawValue))
        collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
      }, completion: { (finished: Bool) in
        self.loadingStatus = .none
      })
    }
  }
}
