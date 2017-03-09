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
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }
  let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let pullToRefresher = UIRefreshControl()
  let loaderNode: LoaderNode

  var collectionView: ASCollectionView?

  let viewModel = DiscoverViewModel()
  var loadingStatus: LoadingStatus = .none {
    didSet {
      switch loadingStatus {
      case .loading:
        break
      case .reloading:
        updateBottomLoaderVisibility(show: false)
      case .loadMore:
        updateBottomLoaderVisibility(show: true)
      case .none:
        updateBottomLoaderVisibility(show: false)
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()

    super.init(node: collectionNode)

    flowLayout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: loaderNode.usedHeight)
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
    initializeNavigationItems()
    title = Strings.discover()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.pullDownToReloadData), for: .valueChanged)

    applyTheme()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if UserManager.shared.isSignedIn && loadingStatus == .none && viewModel.numberOfItemsInSection() == 0 {
      self.pullToRefresher.beginRefreshing()
      loadData(loadingStatus: .loading, completionBlock: {
        self.pullToRefresher.endRefreshing()
      })
    }
    animateRefreshControllerIfNeeded()
  }

  private func initializeNavigationItems() {
    let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    leftNegativeSpacer.width = -10
    let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.settingsButtonTap(_:)))
    navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
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

  func loadData(loadingStatus: LoadingStatus, completionBlock: @escaping () -> ()) {
    self.loadingStatus = loadingStatus

    viewModel.loadDiscoverData { [weak self] (success) in
      guard let strongSelf = self else { return }
      strongSelf.loadingStatus = .none

      completionBlock()

      strongSelf.collectionNode.reloadData()
    }
  }

  func pullDownToReloadData() {
    guard loadingStatus != .reloading else {
      return
    }

    self.pullToRefresher.beginRefreshing()
    loadData(loadingStatus: .reloading, completionBlock: {
      self.pullToRefresher.endRefreshing()
    })
  }
}

// MARK: - Action
extension DiscoverViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }
}

// MARK: - Reload Footer
extension DiscoverViewController {
  func updateBottomLoaderVisibility(show: Bool) {
    if Thread.isMainThread {
      reloadFooter(show: show)
    } else {
      DispatchQueue.main.async {
        self.reloadFooter(show: show)
      }
    }
  }

  func reloadFooter(show: Bool) {
    let bottomMargin: CGFloat = show ? -(externalMargin/2) : -(loaderNode.usedHeight - externalMargin/2)
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin, left: 0, bottom: bottomMargin, right: 0)
    loaderNode.updateLoaderVisibility(show: show)
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
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(index: indexPath.item)
    actionForCard(resource: resource)
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: loaderNode.usedHeight)
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

    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection()

    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      defer {
        context.completeBatchFetching(true)
        self!.loadingStatus = .none
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection()

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        let updatedIndexPathRange: [IndexPath]  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: 0)
        })
        collectionNode.insertItems(at: updatedIndexPathRange)
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

// MARK: - Actions For Cards
extension DiscoverViewController {
  func actionForCard(resource: ModelResource?) {
    guard let resource = resource else {
      return
    }
    let registeredType = resource.registeredResourceType

    switch registeredType {
    case Image.resourceType:
      actionForImageResourceType(resource: resource)
    case Author.resourceType:
      actionForAuthorResourceType(resource: resource)
    case ReadingList.resourceType:
      actionForReadingListResourceType(resource: resource)
    case Topic.resourceType:
      actionForTopicResourceType(resource: resource)
    case Text.resourceType:
      actionForTextResourceType(resource: resource)
    case Quote.resourceType:
      actionForQuoteResourceType(resource: resource)
    case Video.resourceType:
      actionForVideoResourceType(resource: resource)
    case Audio.resourceType:
      actionForAudioResourceType(resource: resource)
    case Link.resourceType:
      actionForLinkResourceType(resource: resource)
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }

  fileprivate func actionForImageResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForTopicResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForTextResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForQuoteResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForVideoResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForAudioResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }

  fileprivate func actionForLinkResourceType(resource: ModelResource) {
    //TODO: Implement the right action
  }
}

