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
import Spine

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
  var loadingStatus: LoadingStatus = .none

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin/2, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
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

    applyLocalization()
    observeLanguageChanges()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeNavigationItems()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.pullDownToReloadData), for: .valueChanged)

    applyTheme()
    addObservers()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    NotificationCenter.default.addObserver(self, selector:
      #selector(self.authenticationStatusChanged(_:)), name: AppNotification.authenticationStatusChanged, object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if loadingStatus == .none && viewModel.numberOfItemsInSection(section: Section.cards.rawValue) == 0 {
      loadingStatus = .loading
      self.pullToRefresher.beginRefreshing()
      viewModel.loadDiscoverData { [weak self] (success) in
        guard let strongSelf = self else { return }
        strongSelf.loadingStatus = .none
        strongSelf.pullToRefresher.endRefreshing()
        strongSelf.collectionNode.reloadData()
      }
    }
    animateRefreshControllerIfNeeded()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookStorefront)
  }

  @objc private func authenticationStatusChanged(_: Notification) {
    initializeNavigationItems()
  }

  private func initializeNavigationItems() {
    if !UserManager.shared.isSignedIn {
      navigationItem.leftBarButtonItems = nil
    } else {
      let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
        UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
      leftNegativeSpacer.width = -10
      let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
        UIBarButtonItemStyle.plain, target: self, action:
        #selector(self.settingsButtonTap(_:)))
      navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
    }

    let rightNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    rightNegativeSpacer.width = -10
    let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.searchButtonTap(_:)))
    navigationItem.rightBarButtonItems = [rightNegativeSpacer, searchBarButton]
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

  func pullDownToReloadData() {
    guard loadingStatus != .reloading else {
      return
    }

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Discover,
                                                 action: .PullToRefresh)
    Analytics.shared.send(event: event)
    loadingStatus = .reloading
    self.pullToRefresher.beginRefreshing()
    viewModel.loadDiscoverData { [weak self] (success) in
      guard let strongSelf = self else { return }
      strongSelf.loadingStatus = .none
      strongSelf.pullToRefresher.endRefreshing()
      strongSelf.collectionNode.reloadData()
    }
  }

  func refreshViewControllerData() {
    if loadingStatus == .none {
      viewModel.cancellableOnGoingRequest()
      self.loadingStatus = .loading
      self.pullToRefresher.beginRefreshing()
      viewModel.loadDiscoverData { [weak self] (success) in
        guard let strongSelf = self else { return }
        strongSelf.loadingStatus = .none
        strongSelf.pullToRefresher.endRefreshing()
        strongSelf.collectionNode.reloadData()
      }
    }
  }
}

// MARK: - Action
extension DiscoverViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }

  func searchButtonTap(_ sender: UIBarButtonItem) {
    let searchVC = SearchViewController()
    searchVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(searchVC, animated: true)
  }
}

// MARK: - Reload Footer
extension DiscoverViewController {
  func updateBottomLoaderVisibility(show: Bool) {
    self.loaderNode.updateLoaderVisibility(show: show)
    collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
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
    guard DiscoverViewController.Section.cards.rawValue == section else {
      return loadingStatus == .none ? 0 : 1
    }
    return viewModel.numberOfItemsInSection(section: section)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let section = indexPath.section
    let index = indexPath.row

    return {
      guard section == Section.cards.rawValue else {
        return self.loaderNode
      }
      let baseCardNode = self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
      // Fetch the reading list cards images
      if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(at: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
      }
      baseCardNode.delegate = self
      return baseCardNode
    }
  }
}

extension DiscoverViewController: ASCollectionDelegate {
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
    DispatchQueue.main.async {
      self.updateBottomLoaderVisibility(show: true)
    }

    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cards.rawValue)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Discover,
                                                 action: .LoadMore)
    Analytics.shared.send(event: event)

    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      defer {
        context.completeBatchFetching(true)
        self!.loadingStatus = .none
        DispatchQueue.main.async {
          self!.updateBottomLoaderVisibility(show: false)
        }
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection(section: Section.cards.rawValue)

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        let updatedIndexPathRange: [IndexPath]  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cards.rawValue)
        })
        collectionNode.insertItems(at: updatedIndexPathRange)
      }
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension DiscoverViewController: BaseCardPostNodeDelegate {
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }
    let resource = viewModel.resourceForIndex(index: indexPath.item)
    if let resource = resource as? ModelCommonProperties,
      let penName = resource.penName {
      pushProfileViewController(penName: penName)
    } else if let penName = resource as? PenName  {
      pushProfileViewController(penName: penName)
    }
  }
  
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
    case .follow:
      viewModel.follow(index: index) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(index: index) { (success) in
        didFinishAction?(success)
      }
    default:
      //TODO: handle comment
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resource(at: index) else { return }
    let category: Analytics.Category
    var name: String = (resource as? ModelCommonProperties)?.title ?? ""
    
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
      name = (resource as? Author)?.name ?? ""
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
      name = (resource as? PenName)?.name ?? ""
    default:
      category = .Default
    }

    let analyticsAction = Analytics.Action.actionFrom(cardAction: action)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
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
    case Book.resourceType:
      actionForBookResourceType(resource: resource)
    case PenName.resourceType:
      if let penName = resource as? PenName {
        pushProfileViewController(penName: penName)
      }
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
    //MARK: [Analytics] Event
    let name: String = (resource as? Image)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Image,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    guard resource is Author else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Author)?.name ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Topic,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(withAuthor: resource as? Author)
    navigationController?.pushViewController(topicViewController, animated: true)
  }

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? ReadingList)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .ReadingList,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
  }

  fileprivate func actionForTopicResourceType(resource: ModelResource) {
    guard resource is Topic else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Topic)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Topic,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(withTopic: resource as? Topic)
    navigationController?.pushViewController(topicViewController, animated: true)
  }

  fileprivate func actionForTextResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Text)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Text,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
  }

  fileprivate func actionForQuoteResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Quote)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Quote,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForVideoResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Video)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Video,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAudioResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Audio)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Audio,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForLinkResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? Link)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Link,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForBookResourceType(resource: ModelResource) {
    guard resource is Book else {
      return
    }

    //MARK: [Analytics] Event
    let name: String = (resource as? Book)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .TopicBook,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(withBook: resource as? Book)
    navigationController?.pushViewController(topicViewController, animated: true)
  }
}

// MARK: - Declarations
extension DiscoverViewController {
  enum Section: Int {
    case cards = 0
    case activityIndicator = 1

    static var numberOfSections: Int {
      return 2
    }
  }
}

// MARK: - Notification
extension DiscoverViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.refreshData(_:)), name: AppNotification.shouldRefreshData, object: nil)
  }

  func refreshData(_ notification: Notification) {
    refreshViewControllerData()
  }
}

//MARK: - Localizable implementation
extension DiscoverViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.discover()
    tabBarItem.title = Strings.discover().uppercased()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

