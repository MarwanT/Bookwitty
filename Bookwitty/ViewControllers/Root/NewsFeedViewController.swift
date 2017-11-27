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
import SwiftLoader

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
  let misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
  let introductoryNode = IntroductoryBanner(mode: .welcome)
  

  var loadingStatus: LoadingStatus = .none
  var shouldShowLoader: Bool {
    return (loadingStatus != .none && loadingStatus != .reloading)
  }
  var shouldDisplayMisfortuneNode: Bool {
    guard let misfortuneMode = viewModel.misfortuneNodeMode, !shouldShowLoader else {
       return false
    }
    misfortuneNode.mode = misfortuneMode
    return true
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
    flowLayout.sectionInset = UIEdgeInsets.zero
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
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addObservers()
    initializeNavigationItems()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    penNameSelectionNode.delegate = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.pullDownToReloadData), for: .valueChanged)
    
    misfortuneNode.delegate = self
    misfortuneNode.style.height = ASDimensionMake(collectionNode.frame.height)
    misfortuneNode.style.width = ASDimensionMake(collectionNode.frame.width)
    
    applyTheme()
    applyLocalization()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateRefreshControllerIfNeeded()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.NewsFeed)

    self.misfortuneNode.style.height = ASDimensionMake(collectionNode.frame.height)
    self.misfortuneNode.style.width = ASDimensionMake(collectionNode.frame.width)
    
    reloadPenNamesNode()
    if viewModel.numberOfItemsInSection(section: Section.cards.rawValue) == 0 {
      refreshViewControllerData()
    }
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

  fileprivate func initializeNavigationItems() {
    if !UserManager.shared.isSignedIn {
      navigationItem.leftBarButtonItems = nil
      return
    }

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
      self.loadingStatus = .loading
      self.updateCollection(with: nil, loaderSection: true, penNamesSection: false, orReloadAll: false, completionBlock: nil)
      self.viewModel.loadNewsfeed { (success) in
        self.loadingStatus = .none
        self.updateCollection(with: nil, loaderSection: false, penNamesSection: false, orReloadAll: true, completionBlock: nil)
      }
    }
  }

  /**
   * User should not directly call this should, it should be triggered from
   * UIRefreshControl's valueChanged target action
   */
  func pullDownToReloadData() {
    guard pullToRefresher.isRefreshing else {
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }
    guard loadingStatus == .none else {
      pullToRefresher.endRefreshing()
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }
    
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .NewsFeed,
                                                 action: .PullToRefresh)
    Analytics.shared.send(event: event)

    self.loadingStatus = .reloading
    self.pullToRefresher.beginRefreshing()

    viewModel.penNameRequest { (success) in
      self.viewModel.nextPage = nil
      self.updateCollection(with: nil, loaderSection: true, penNamesSection: false, orReloadAll: false, completionBlock: nil)
      self.reloadPenNamesNode()
      self.viewModel.loadNewsfeed { (success) in
        self.loadingStatus = .none
        self.updateCollection(with: nil, loaderSection: false, penNamesSection: false, orReloadAll: true, completionBlock: { (sucess) in
          self.pullToRefresher.endRefreshing()
        })
      }
    }
  }

  func reloadPenNamesNode() {
    penNameSelectionNode.loadData(penNames: viewModel.penNames, withSelected: viewModel.defaultPenName)
  }
}

extension NewsFeedViewController: PenNameSelectionNodeDelegate {
  func penNameSelectionNodeNeeds(node: PenNameSelectionNode, reload: Bool, penNameChanged: Bool) {
    if reload {
      self.updateCollection(with: nil, loaderSection: false, penNamesSection: true, orReloadAll: penNameChanged, completionBlock: nil)
    }
  }

  func didSelectPenName(penName: PenName, sender: PenNameSelectionNode) {
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .NewsFeed,
                                                 action: .SelectPenName)
    Analytics.shared.send(event: event)

    if let scrollView = scrollView {
      penNameSelectionNode.alpha = 1.0
      scrollView.contentOffset = CGPoint(x: 0, y: 0.0)
    }
    viewModel.cancellableOnGoingRequest()
    viewModel.data = []
    viewModel.nextPage = nil
    self.loadingStatus = .loading
    self.updateCollection(with: nil, loaderSection: false, penNamesSection: false, orReloadAll: true, completionBlock: nil)
    viewModel.didUpdateDefaultPenName(penName: penName, completionBlock: {  didSaveDefault in
      if didSaveDefault {
        self.viewModel.loadNewsfeed { (success) in
          self.loadingStatus = .none
          self.updateCollection(with: nil, loaderSection: false, penNamesSection: false, orReloadAll: true, completionBlock: nil)
        }
      }
    })
  }
}
// MARK: - Notification
extension NewsFeedViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(refreshData(_:)), name: AppNotification.authenticationStatusChanged, object: nil)

    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)

    observeLanguageChanges()
  }

  func updatedResources(_ notification: NSNotification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems.filter({ $0.section == Section.cards.rawValue })

    guard let identifiers = notification.object as? [String],
      identifiers.count > 0,
      visibleItemsIndexPaths.count > 0 else {
      return
    }

    let indexPathForAffectedItems = viewModel.indexPathForAffectedItems(resourcesIdentifiers: identifiers, visibleItemsIndexPaths: visibleItemsIndexPaths)
    updateCollectionNodes(indexPathForAffectedItems: indexPathForAffectedItems)
  }

  func refreshData(_ notification: Notification) {
    if UserManager.shared.isSignedIn {
      initializeNavigationItems()
    } else {
      signOutAction()
    }
  }

  func signOutAction() {
    if let scrollView = scrollView {
      penNameSelectionNode.alpha = 1.0
      scrollView.contentOffset = CGPoint(x: 0, y: 0.0)
    }

    reloadPenNamesNode()
    viewModel.cancellableOnGoingRequest()
    viewModel.data = []
    viewModel.nextPage = nil
    self.updateCollection(with: nil, loaderSection: false, penNamesSection: false, orReloadAll: true, completionBlock: nil)
  }
}
// MARK: - Themeable
extension NewsFeedViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
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

// MARK: - Reload Footer
extension NewsFeedViewController {
  func updateCollectionNodes(indexPathForAffectedItems: [IndexPath]) {
    let cards = indexPathForAffectedItems.map({ collectionNode.nodeForItem(at: $0) })
    cards.forEach({ card in
      guard let card = card as? BaseCardPostNode else {
        return
      }
      guard let indexPath = card.indexPath, let commonResource =  viewModel.resourceForIndex(index: indexPath.row) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = commonResource
    })
  }
  
  func updateCollection(with itemIndices: [IndexPath]? = nil, shouldReloadItems reloadItems: Bool = false, introductorySection: Bool = false, loaderSection: Bool = false, penNamesSection: Bool = false, orReloadAll reloadAll: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData(completion: { 
        completionBlock?(true)
      })
    } else {
      collectionNode.performBatchUpdates({
        // Always relaod misfortune section
        collectionNode.reloadSections(IndexSet(integer: Section.misfortune.rawValue))
        
        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if penNamesSection {
          collectionNode.reloadSections(IndexSet(integer: Section.penNames.rawValue))
        }
        if introductorySection {
          collectionNode.reloadSections(IndexSet(integer: Section.introductoryBanner.rawValue))
        }
        if let itemIndices = itemIndices, itemIndices.count > 0 {
          if reloadItems {
            collectionNode.reloadItems(at: itemIndices)
          }else {
            collectionNode.insertItems(at: itemIndices)
          }
        }
      }, completion: completionBlock)
    }
  }
}

extension NewsFeedViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case NewsFeedViewController.Section.cards.rawValue:
      return viewModel.numberOfItemsInSection(section: section)
    case NewsFeedViewController.Section.penNames.rawValue:
      return 1
    case NewsFeedViewController.Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    case NewsFeedViewController.Section.misfortune.rawValue:
      return shouldDisplayMisfortuneNode ? 1 : 0
    case NewsFeedViewController.Section.introductoryBanner.rawValue:
      return viewModel.shouldDisplayIntroductoryBanner ? 1 : 0
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let section = indexPath.section
    return {
      if section == Section.cards.rawValue {
        let baseCardNode = self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
        if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
          !readingListCell.node.isImageCollectionLoaded {
          let max = readingListCell.node.maxNumberOfImages
          self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
            if let imageCollection = imageCollection, imageCollection.count > 0 {
              readingListCell.node.prepareImages(imageCount: imageCollection.count)
              readingListCell.node.loadImages(with: imageCollection)
            }
          })
        } else if let bookCard = baseCardNode as? BookCardPostCellNode, let resource = self.viewModel.resourceForIndex(index: index) {
          bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.newsFeed) ?? .topic == .product)
        }
        baseCardNode.delegate = self
        return baseCardNode
      } else if section == Section.penNames.rawValue {
        return self.penNameSelectionNode
      } else if section == Section.activityIndicator.rawValue {
        return self.loaderNode
      } else if section == Section.misfortune.rawValue { // Section.misfortune
        return self.misfortuneNode
      } else { // Section.introductoryBanner.rawValue
        self.introductoryNode.delegate = self
        return self.introductoryNode
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is PenNameSelectionNode {
      penNameSelectionNode.setNeedsLayout()
    } else if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: shouldShowLoader)
    } else if node is MisfortuneNode {
      misfortuneNode.mode = viewModel.misfortuneNodeMode ?? MisfortuneNode.Mode.empty
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(index: indexPath.row), let commonResource =  resource as? ModelCommonProperties else {
        return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
      if let bookCard = card as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.newsFeed) ?? .topic == .product)
      }
    }
  }
}

extension NewsFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      if viewModel.misfortuneNodeMode != nil, !shouldShowLoader {
        return UIEdgeInsets.zero
      } else {
        switch (section) {
        case Section.introductoryBanner.rawValue:
          return UIEdgeInsets.zero
        default:
          return UIEdgeInsets(top: 0, left: 0, bottom: externalMargin/2, right: 0)
        }
      }
  }
}


// MARK - BaseCardPostNode Delegate
extension NewsFeedViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(index: indexPath.item)
    if let resource = resource as? ModelCommonProperties,
      let penName = resource.penName {
      pushProfileViewController(penName: penName)

      //MARK: [Analytics] Event
      let category: Analytics.Category
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
      default:
        category = .Default
      }

      let event: Analytics.Event = Analytics.Event(category: category,
                                                   action: .GoToPenName,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    } else if let penName = resource as? PenName  {
      pushProfileViewController(penName: penName)

      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                   action: .GoToDetails,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    }
  }

  private func actionInfoHandler(at indexPath: IndexPath) {
    guard let resource = viewModel.resourceForIndex(index: indexPath.item) else {
      return
    }

    pushPenNamesListViewController(with: resource)
  }

  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }
    
    switch action {
    case .userProfile:
      userProfileHandler(at: indexPath)
    case .actionInfo:
      actionInfoHandler(at: indexPath)
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
    case .comment:
      guard let resource = viewModel.resourceForIndex(index: index) else { return }
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = viewModel.resourceForIndex(index: index),
        let identifier = resource.id else { return }
      self.showMoreActionSheet(identifier: identifier, actions: [.report(.content)], completion: { (success: Bool) in
        didFinishAction?(success)
      })
    default:
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resourceForIndex(index: index) else { return }
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

    let analyticsAction = Analytics.Action.actionFrom(cardAction: action, with: category)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func cardNode(card: BaseCardPostNode, didRequestAction action: BaseCardPostNode.Action, from: ASDisplayNode) {
    guard let indexPath = collectionNode.indexPath(for: card),
      let resource = viewModel.resourceForIndex(index: indexPath.item) as? ModelCommonProperties else {
        return
    }

    let analyticsAction: Analytics.Action
    switch(action) {
    case .listComments:
      pushCommentsViewController(for: resource)
      analyticsAction = .ViewTopComment
    case .publishComment:
      CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentCommentId: nil)
      analyticsAction = .AddComment
    }

    //MARK: [Analytics] Event
    let category: Analytics.Category
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
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int) {
    //Empty Implementation
  }
}

extension NewsFeedViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == Section.cards.rawValue else {
      return
    }
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
      self.updateCollection(loaderSection: true)
    }


    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cards.rawValue)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .NewsFeed,
                                                 action: .LoadMore)
    Analytics.shared.send(event: event)

    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      var updatedIndexPathRange: [IndexPath]? = nil
      defer {
        self?.loadingStatus = .none
        self?.updateCollection(with: updatedIndexPathRange, loaderSection: true, penNamesSection: true, orReloadAll: false, completionBlock: nil)
        context.completeBatchFetching(true)
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection(section: Section.cards.rawValue)

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        updatedIndexPathRange = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cards.rawValue)
        })
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
    if scrollView.contentOffset.y <= penNameHeight && !viewModel.shouldDisplayIntroductoryBanner {
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
    guard let resource = resource,
      !DataManager.shared.isReported(resource) else {
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

        //MARK: [Analytics] Event
        let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                     action: .GoToDetails,
                                                     name: penName.name ?? "")
        Analytics.shared.send(event: event)
      }
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }

  func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    nodeVc.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  func pushGenericViewControllerCard(resource: Resource, title: String? = nil) {
    guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
      return
    }

    cardNode.baseViewModel?.resource = resource as? ModelCommonProperties
    let genericVC = CardDetailsViewController(node: cardNode, title: title, resource: resource)
    genericVC.hidesBottomBarWhenPushed = true
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
    let event: Analytics.Event = Analytics.Event(category: .Author,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
    topicViewController.hidesBottomBarWhenPushed = true
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
    topicViewController.initialize(with: resource as? ModelCommonProperties)
    topicViewController.hidesBottomBarWhenPushed = true
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
    guard let resource = resource as? Book else {
      return
    }

    let isProduct = (viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.newsFeed) ?? .topic == .product)

    //MARK: [Analytics] Event
    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: isProduct ? .BookProduct : .TopicBook,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    if !isProduct {
      let topicViewController = TopicViewController()
      topicViewController.initialize(with: resource as ModelCommonProperties)
      topicViewController.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(topicViewController, animated: true)
    } else {
      guard !resource.isPandacraft else {
        if let url = resource.canonicalURL {
          WebViewController.present(url: url)
        }
        return
      }
      let bookDetailsViewController = BookDetailsViewController()
      bookDetailsViewController.initialize(with: resource)
      bookDetailsViewController.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(bookDetailsViewController, animated: true)
    }
  }
}

// MARK: - Declarations
extension NewsFeedViewController {
  enum Section: Int {
    case introductoryBanner = 0
    case penNames
    case cards
    case activityIndicator
    case misfortune

    static var numberOfSections: Int {
      return 5
    }
  }
}

//MARK: - Localizable implementation
extension NewsFeedViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.bookwitty()
    tabBarItem.title = Strings.news().uppercased()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()

    //Reload the Data upon language change
    refreshViewControllerData()
  }
}

// MARK: - 
extension NewsFeedViewController: MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?) {
    guard let action = action else {
      return
    }
    
    switch action {
    case .tryAgain:
      refreshViewControllerData()
    case .settings:
      AppDelegate.openSettings()
    default:
      break
    }
  }
}

// MARK: - Introductory Node Delegate
extension NewsFeedViewController: IntroductoryBannerDelegate {
  func introductoryBannerDidTapDismissButton(_ introductoryBanner: IntroductoryBanner) {
    viewModel.shouldDisplayIntroductoryBanner = false
    updateCollection(introductorySection: true)
  }
}

// MARK: - Compose comment delegate implementation
extension NewsFeedViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
}
