//
//  NewsFeedViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//
import UIKit
import AsyncDisplayKit
import Spine

class NewsFeedViewController: ASViewController<ASCollectionNode> {
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
  let penNameSelectionNode = PenNameSelectionNode()
  let loaderNode: LoaderNode

  var loadingStatus: LoadingStatus = .none {
    didSet {
      switch loadingStatus {
      case .loading:
        break
      case .reloading:
        updateBottomLoaderVisibility(show: true)
      case .loadMore:
        updateBottomLoaderVisibility(show: true)
      case .none:
        updateBottomLoaderVisibility(show: false)
      }
    }
  }
  var collectionView: ASCollectionView?
  var scrollView: UIScrollView? {
    if let collectionView = collectionView {
      return collectionView as UIScrollView
    }
    return nil
  }
  let scrollingThreshold: CGFloat = 25.0
  let viewModel = NewsFeedViewModel()
  var isFirstRun: Bool = true

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    super.init(node: collectionNode)

    flowLayout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: LoaderNode.defaultNodeHeight)
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

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Strings.news()
    addObservers()
    initializeNavigationItems()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    penNameSelectionNode.delegate = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.pullDownToReloadData), for: .valueChanged)

    applyTheme()
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
  
  private func initializeNavigationItems() {
    let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    leftNegativeSpacer.width = -10
    let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.settingsButtonTap(_:)))
    navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
  }
  
  func refreshViewControllerData() {
    if UserManager.shared.isSignedIn {
      viewModel.cancellableOnGoingRequest()
      self.pullToRefresher.beginRefreshing()
      loadData(withPenNames: true, loadingStatus: .loading, completionBlock: {
        self.pullToRefresher.endRefreshing()
      })
    }
  }

  func pullDownToReloadData() {
    guard loadingStatus != .reloading else {
      return
    }
    
    self.pullToRefresher.beginRefreshing()
    loadData(withPenNames: true, loadingStatus: .reloading, completionBlock: {
      self.pullToRefresher.endRefreshing()
    })
  }

  func loadData(withPenNames reloadPenNames: Bool = true, loadingStatus: LoadingStatus, completionBlock: @escaping () -> ()) {
    self.loadingStatus = loadingStatus

    viewModel.loadNewsfeed { [weak self] (success) in
      guard let strongSelf = self else { return }
      strongSelf.loadingStatus = .none

      completionBlock()
      if success {
        strongSelf.collectionNode.reloadData(completion: {
          if reloadPenNames || !strongSelf.penNameSelectionNode.hasData() {
            strongSelf.reloadPenNamesNode()
          }
        })
      }
    }
  }

  func reloadPenNamesNode() {
    penNameSelectionNode.loadData(penNames: viewModel.penNames, withSelected: viewModel.defaultPenName)
  }

}

extension NewsFeedViewController {
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
    let bottomMargin: CGFloat
    if show {
      bottomMargin = -(self.externalMargin/2)
    } else {
      //If we have Zero data items this means that we are only showing the pen-name-selection-node
      bottomMargin = self.viewModel.data.count == 0 ? 0.0 : -(LoaderNode.defaultNodeHeight - self.externalMargin/2)
    }

    self.flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomMargin, right: 0)
    self.loaderNode.updateLoaderVisibility(show: show)
  }
}

extension NewsFeedViewController: PenNameSelectionNodeDelegate {
  func didSelectPenName(penName: PenName, sender: PenNameSelectionNode) {
    if let scrollView = scrollView {
      penNameSelectionNode.alpha = 1.0
      scrollView.contentOffset = CGPoint(x: 0, y: 0.0)
    }
    viewModel.cancellableOnGoingRequest()
    viewModel.data = []
    collectionNode.reloadData()
    viewModel.didUpdateDefaultPenName(penName: penName, completionBlock: {  didSaveDefault in
      if didSaveDefault {
        loadData(withPenNames: false, loadingStatus: .reloading, completionBlock: { })
      }
    })
  }
}
// MARK: - Notification
extension NewsFeedViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.refreshData(_:)), name: AppNotification.shouldRefreshData, object: nil)
  }

  func refreshData(_ notification: Notification) {
    refreshViewControllerData()
  }
}
// MARK: - Themeable
extension NewsFeedViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    pullToRefresher.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
  }
}

// MARK: - Action
extension NewsFeedViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }
}

extension NewsFeedViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSection()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    
    return {
      if(index != 0) {
        let baseCardNode = self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
        if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
          !readingListCell.node.isImageCollectionLoaded {
          let max = readingListCell.node.maxNumberOfImages
          self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
            if let imageCollection = imageCollection, imageCollection.count > 0 {
              readingListCell.node.loadImages(with: imageCollection)
            }
          })
        }
        baseCardNode.delegate = self
        return baseCardNode
      } else {
        return self.penNameSelectionNode
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is PenNameSelectionNode {
      penNameSelectionNode.setNeedsLayout()
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    switch kind {
    case UICollectionElementKindSectionFooter: return loaderNode
    default: return ASCellNode()
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension NewsFeedViewController: BaseCardPostNodeDelegate {
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
      if let sharingInfo: [String] = viewModel.sharingContent(index: index) {
        presentShareSheet(shareContent: sharingInfo)
      }
    default:
      //TODO: handle comment
      break
    }
  }
}

extension NewsFeedViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(index: indexPath.item)
    actionForCard(resource: resource)
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

extension NewsFeedViewController: UIScrollViewDelegate {
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollToTheRightPosition(scrollView: scrollView)
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if(!decelerate) {
      scrollToTheRightPosition(scrollView: scrollView)
    }
  }

  private func scrollToTheRightPosition(scrollView: UIScrollView) {
    let penNameHeight = penNameSelectionNode.occupiedHeight
    if scrollView.contentOffset.y <= penNameHeight {
      if(scrollView.contentOffset.y <= scrollingThreshold) {
        UIView.animate(withDuration: 0.3, animations: {
          self.penNameSelectionNode.alpha = 1.0
          scrollView.contentOffset = CGPoint(x: 0, y: 0.0)
          //TODO: use inset to hide the bar:
          //scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
      } else {
        UIView.animate(withDuration: 0.3, animations: {
          self.penNameSelectionNode.alpha = 0.4
          scrollView.contentOffset = CGPoint(x: 0, y: penNameHeight)
          //TODO: use inset to hide the bar:
          //scrollView.contentInset = UIEdgeInsets(top: -penNameHeight, left: 0, bottom: 0, right: 0)
        })
      }
    }
  }
}

// MARK: - Actions For Cards
extension NewsFeedViewController {
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
    case Book.resourceType:
      actionForBookResourceType(resource: resource)
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }

  func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  func pushGenericViewControllerCard(resource: Resource, title: String? = nil) {
    guard let cardNode = CardFactory.shared.createCardFor(resource: resource) else {
      return
    }
    let genericVC = CardDetailsViewController(node: cardNode, title: title, resource: resource)
    navigationController?.pushViewController(genericVC, animated: true)
  }

  fileprivate func actionForImageResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    guard resource is Author else {
      return
    }

    let topicViewController = TopicViewController()
    topicViewController.initialize(withAuthor: resource as? Author)
    navigationController?.pushViewController(topicViewController, animated: true)
  }

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    pushPostDetailsViewController(resource: resource)
  }

  fileprivate func actionForTopicResourceType(resource: ModelResource) {
    guard resource is Topic else {
      return
    }

    let topicViewController = TopicViewController()
    topicViewController.initialize(withTopic: resource as? Topic)
    navigationController?.pushViewController(topicViewController, animated: true)
  }

  fileprivate func actionForTextResourceType(resource: ModelResource) {
    pushPostDetailsViewController(resource: resource)
  }

  fileprivate func actionForQuoteResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForVideoResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAudioResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForLinkResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForBookResourceType(resource: ModelResource) {
    guard resource is Book else {
      return
    }

    let topicViewController = TopicViewController()
    topicViewController.initialize(withBook: resource as? Book)
    navigationController?.pushViewController(topicViewController, animated: true)
  }
}
