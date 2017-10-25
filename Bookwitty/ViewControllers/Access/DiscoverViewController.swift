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
import SwiftLoader

class DiscoverViewController: ASViewController<ASDisplayNode> {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let pullToRefresher = UIRefreshControl()
  fileprivate let loaderNode: LoaderNode
  fileprivate let collectionNode: ASCollectionNode
  fileprivate let segmentedNode: SegmentedControlNode
  fileprivate let contentTitleHeaderNode: SectionTitleHeaderNode
  fileprivate let booksTitleHeaderNode: SectionTitleHeaderNode
  fileprivate let pagesTitleHeaderNode: SectionTitleHeaderNode
  fileprivate let discoverNode: DiscoverNode
  fileprivate let introductoryNode = IntroductoryBanner(mode: .discover)

  fileprivate var collectionView: ASCollectionView?

  let viewModel = DiscoverViewModel()
  var loadingStatus: LoadingStatus = .none

  fileprivate var segments: [Segment] = [.content(index: 0), .books(index: 1), .pages(index: 2)]
  fileprivate var activeSegment: Segment

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    discoverNode = DiscoverNode()
    collectionNode = discoverNode.collectionNode
    segmentedNode = discoverNode.segmentedNode

    loaderNode = LoaderNode()
    activeSegment = segments[0]
    contentTitleHeaderNode = SectionTitleHeaderNode()
    booksTitleHeaderNode = SectionTitleHeaderNode()
    pagesTitleHeaderNode = SectionTitleHeaderNode()
    super.init(node: discoverNode)

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
    initializeComponents()

    applyTheme()
    addObservers()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if loadingStatus == .none && viewModel.numberOfItems(for: activeSegment) == 0 {
      loadingStatus = .loading
      updateCollection(loaderSection: true)
      viewModel.refreshData(for: activeSegment, afterDataEmptied: {
        self.updateCollection(orReloadAll: true)
      })  { [weak self] (success, segment) in
        guard let strongSelf = self else { return }
        strongSelf.loadingStatus = .none
        strongSelf.updateCollection(orReloadAll: true)
      }
    }
    animateRefreshControllerIfNeeded()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookStorefront)
  }

  private func initializeComponents() {
    collectionNode.delegate = self
    collectionNode.dataSource = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.pullDownToReloadData), for: .valueChanged)

    segmentedNode.initialize(with: segments.map({ $0.name }))
    segmentedNode.selectedSegmentChanged = { [weak self] (segmentedControlNode: SegmentedControlNode, index: Int) in
      self?.segmentedNode(segmentedControlNode: segmentedControlNode, didSelectSegmentIndex: index)
    }

    setupHeaderTitles()
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {
    guard loadingStatus == .none else {
      self.activeSegment = segment(withIndex: index)
      updateCollection(cardsSection: true, loaderSection: true, headerSection: true)
      return
    }

    self.activeSegment = segment(withIndex: index)
    loadingStatus = .loading
    updateCollection(cardsSection: true, loaderSection: true, headerSection: true)
    viewModel.loadDataIfNeeded(for: activeSegment, afterDataEmptied: {
      self.updateCollection(cardsSection: true)
    }) { [weak self] (success, segment) in
      guard let strongSelf = self else { return }
      strongSelf.loadingStatus = .none
      if strongSelf.activeSegment.index == segment.index {
        strongSelf.updateCollection(cardsSection: true, loaderSection: true)
      }
    }


    var analyticsAction: Analytics.Action = .Default
    switch activeSegment {
    case .pages:
      analyticsAction = .GoToPages
    case .books:
      analyticsAction = .GoToBooks
    case .content: fallthrough
    default:
      analyticsAction = .GoToContent
    }

    let event: Analytics.Event = Analytics.Event(category: .Discover,
                                                 action: analyticsAction)
    Analytics.shared.send(event: event)
  }

  fileprivate func setupHeaderTitles() {
    contentTitleHeaderNode.setTitle(title: Strings.see_whats_happening_on_bookwitty(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber10(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber9())
    booksTitleHeaderNode.setTitle(title: Strings.books_you_may_be_interested_in(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber4(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber3())
    pagesTitleHeaderNode.setTitle(title: Strings.pages_you_may_be_interested_in(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber6(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber5())
  }

  private func initializeNavigationItems() {

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


  func reloadViewData() -> Bool {
    /** Discussion
     * TODO: Merge reloadViewData with refreshViewControllerData function, since they almost do the they job.
     * The only difference is that 'refreshViewControllerData' function has the 'afterDataEmptied' block which
     * removes all the cells that were showing prior to the load operation + it used the .loading not .reloading
     * option which in turn shows the bottom/loadmore loader.
     **/
    guard loadingStatus == .none else {
      pullToRefresher.endRefreshing()
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return false
    }

    //Make sure the view is loaded
    guard self.isViewLoaded else {
      return false
    }

    loadingStatus = .reloading
    updateCollection(loaderSection: true)
    self.pullToRefresher.beginRefreshing()
    viewModel.refreshData(for: activeSegment) { [weak self] (success, segment) in
      guard let strongSelf = self else { return }
      strongSelf.updateCollection(orReloadAll: true)
      strongSelf.pullToRefresher.endRefreshing()
      strongSelf.loadingStatus = .none
    }
    return true
  }

  func pullDownToReloadData() {
    guard pullToRefresher.isRefreshing else {
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }

    let didStartReloadingData = reloadViewData()
    if didStartReloadingData {
      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(category: .Discover,
                                                   action: .PullToRefresh)
      Analytics.shared.send(event: event)
    }
  }

  func refreshViewControllerData() {
    if loadingStatus == .none {
      viewModel.cancelOnGoingRequest()
      self.loadingStatus = .loading
      updateCollection(loaderSection: true)
      self.pullToRefresher.beginRefreshing()
      viewModel.refreshData(for: activeSegment, afterDataEmptied: {
        self.updateCollection(orReloadAll: true)
      })  { [weak self] (success, segment) in
        guard let strongSelf = self else { return }
        strongSelf.loadingStatus = .none
        strongSelf.pullToRefresher.endRefreshing()
        strongSelf.updateCollection(orReloadAll: true)
      }
    }
  }
}

//MARK: - UICollectionViewDelegateFlowLayout implementation
extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    switch (section) {
    case Section.cards.rawValue:
      return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    case Section.header.rawValue:
      return  UIEdgeInsets(top: externalMargin, left: 0.0, bottom: internalMargin, right: 0.0)
    case Section.activityIndicator.rawValue:
      return  UIEdgeInsets(top: externalMargin/2, left: 0.0, bottom: externalMargin/2, right: 0.0)
    default:
      return UIEdgeInsets.zero
    }
  }
}

// MARK: - Action
extension DiscoverViewController {
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
  }
}

// MARK: - Themeable
extension DiscoverViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

extension DiscoverViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch(section) {
    case DiscoverViewController.Section.introductoryBanner.rawValue:
      return viewModel.shouldDisplayIntroductoryBanner ? 1 : 0
    case DiscoverViewController.Section.header.rawValue:
      return 1
    case DiscoverViewController.Section.cards.rawValue:
      return viewModel.numberOfItems(for: activeSegment)
    case DiscoverViewController.Section.activityIndicator.rawValue:
      return (loadingStatus == .none || loadingStatus == .reloading) ? 0 : 1
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let section = indexPath.section
    let index = indexPath.row

    return {
      switch section {
      case Section.cards.rawValue:
        let cellNode = self.viewModel.nodeForItem(for: self.activeSegment, atIndex: index) ?? ASCellNode()
        
        switch (self.activeSegment) {
        case .pages:
          guard let pageNode = cellNode as? PageCellNode, let resource = self.viewModel.resourceForIndex(for: self.activeSegment, index: index) as? ModelCommonProperties else {
            return cellNode
          }
          pageNode.setup(with: resource.coverImageUrl, title: resource.title)
          return pageNode
        case .books:
          return cellNode
        case .content: fallthrough
        default:
          guard let baseCardNode = cellNode as? BaseCardPostNode else {
            return cellNode
          }
          // Fetch the reading list cards images
          if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
            !readingListCell.node.isImageCollectionLoaded {
            let max = readingListCell.node.maxNumberOfImages
            self.viewModel.loadReadingListImages(for: self.activeSegment, at: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
              if let imageCollection = imageCollection, imageCollection.count > 0 {
                readingListCell.node.prepareImages(imageCount: imageCollection.count)
                readingListCell.node.loadImages(with: imageCollection)
              }
            })
          } else if let bookCard = baseCardNode as? BookCardPostCellNode, let resource = self.viewModel.resourceForIndex(for: self.activeSegment, index: index) {
            bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.discover) ?? .topic == .product)
          }
          baseCardNode.delegate = self
          return baseCardNode
        }
      case Section.header.rawValue:
        return self.headerForSegment(segment: self.activeSegment)
      case Section.activityIndicator.rawValue:
        return self.loaderNode
      case Section.introductoryBanner.rawValue:
        self.introductoryNode.delegate = self
        return self.introductoryNode
      default:
        return ASCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }
    switch (indexPath.section) {
    case Section.cards.rawValue:
      updateCellNodeItem(for: activeSegment, node: node, index: indexPath.row)
    default:
      if node === loaderNode {
        self.loaderNode.updateLoaderVisibility(show: loadingStatus != .none && loadingStatus != .reloading)
      }
    }
  }

  func headerForSegment(segment: Segment) -> SectionTitleHeaderNode {
    switch segment {
    case .content:
      return contentTitleHeaderNode
    case .books:
      return booksTitleHeaderNode
    case .pages:
      fallthrough
    default:
      return pagesTitleHeaderNode
    }
  }

  func updateCellNodeItem(for segment: Segment, node: ASCellNode, index: Int) {
    guard let resource = viewModel.resourceForIndex(for: segment, index: index),
      let modelCommonProperties = resource as? ModelCommonProperties else {
      return
    }
    switch (segment) {
    case .pages:
      if let page = node as? PageCellNode {
        page.setup(with: modelCommonProperties.coverImageUrl, title: modelCommonProperties.title)
      }
    case .content:
      if let card = node as? BaseCardPostNode,
        let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: modelCommonProperties), !sameInstance {
        card.baseViewModel?.resource = modelCommonProperties
      }
      if let bookCard = node as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.discover) ?? .topic == .product)
      }
    case .books:
      guard let book = node as? BookNode, let bookResource = viewModel.bookValues(for: resource) else {
        return
      }

      book.title = bookResource.title
      book.author = bookResource.author
      book.format = bookResource.format
      book.price = bookResource.price
      book.imageUrl = bookResource.imageUrl
    default: break
    }
  }
}

extension DiscoverViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == Section.cards.rawValue else {
      return
    }

    let resource = viewModel.resourceForIndex(for: activeSegment, index: indexPath.item)
    actionForCard(resource: resource)
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage(for: activeSegment)
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

    let initialLastIndexPath: Int = viewModel.numberOfItems(for: activeSegment)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Discover,
                                                 action: .LoadMore)
    Analytics.shared.send(event: event)

    // Fetch next page data
    viewModel.loadNextPage(for: activeSegment) { [weak self] (success, segment) in
      var updatedIndexPathRange: [IndexPath]? = nil
      defer {
        context.completeBatchFetching(true)
        self?.loadingStatus = .none
        if let activeSegment = self?.activeSegment,
          activeSegment.index == segment.index {
          self?.updateCollection(with: updatedIndexPathRange, loaderSection: true)
        }
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItems(for: strongSelf.activeSegment)

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        updatedIndexPathRange  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cards.rawValue)
        })
      }
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension DiscoverViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(for: activeSegment, index: indexPath.item)
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
    guard let resource = viewModel.resourceForIndex(for: activeSegment, index: indexPath.item) else {
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
      viewModel.witContent(for: activeSegment, index: index) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(for: activeSegment, index: index) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(for: activeSegment, index: index) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow(for: activeSegment, index: index) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(for: activeSegment, index: index) { (success) in
        didFinishAction?(success)
      }
    case .comment:
      guard let resource = viewModel.resourceForIndex(for: activeSegment, index: index) else { return }
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = viewModel.resourceForIndex(for: activeSegment, index: index),
        let identifier = resource.id else { return }
      self.showMoreActionSheet(identifier: identifier, actions: [.report(.content)], completion: { (success: Bool) in
        didFinishAction?(success)
      })
    default:
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resourceForIndex(for: activeSegment, index: index) else { return }
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
      let resource = viewModel.resourceForIndex(for: activeSegment, index: indexPath.item) as? ModelCommonProperties else {
        return
    }

    let analyticsAction: Analytics.Action
    switch(action) {
    case .listComments:
      pushCommentsViewController(for: resource)
      analyticsAction = .ViewTopComment
    case .publishComment:
      CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentCommentIdentifier: nil)
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

// MARK: - Actions For Cards
extension DiscoverViewController {
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
    let event: Analytics.Event = Analytics.Event(category: .Topic,
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
    let isProduct = (viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.discover) ?? .topic == .product)

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
extension DiscoverViewController {
  enum Section: Int {
    case introductoryBanner = 0
    case header
    case cards
    case activityIndicator

    static var numberOfSections: Int {
      return 4
    }
  }

  enum Segment {
    case content(index: Int)
    case books(index: Int)
    case pages(index: Int)
    case none

    var name: String {
      switch self {
      case .content:
        return Strings.content()
      case .books:
        return Strings.books()
      case .pages:
        return Strings.pages()
      case .none:
        return ""
      }
    }

    var index: Int {
      switch self {
      case .content(let index):
        return index
      case .books(let index):
        return index
      case .pages(let index):
        return index
      case .none:
        return NSNotFound
      }
    }
  }

  fileprivate func segment(withIndex index: Int) -> Segment {
    guard let segment = self.segments.filter({ $0.index == index }).first else {
      return .none
    }

    return segment
  }
}

// MARK: - Notification
extension DiscoverViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.refreshData(_:)), name: AppNotification.shouldRefreshData, object: nil)

    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
  }

  func refreshData(_ notification: Notification) {
    refreshViewControllerData()
  }

  @objc
  fileprivate func updatedResources(_ notification: NSNotification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems.filter({ $0.section == Section.cards.rawValue })

    guard let identifiers = notification.object as? [String],
      identifiers.count > 0,
      visibleItemsIndexPaths.count > 0 else {
        return
    }

    let indexPathForAffectedItems = viewModel.indexPathForAffectedItems(for: activeSegment, resourcesIdentifiers: identifiers, visibleItemsIndexPaths: visibleItemsIndexPaths)
    if indexPathForAffectedItems.count > 0 {
      updateCollectionNodes(indexPathForAffectedItems: indexPathForAffectedItems)
    }
  }
}

// MARK: - Reload Footer
extension DiscoverViewController {
  func updateCollectionNodes(indexPathForAffectedItems: [IndexPath]) {
    let cards = indexPathForAffectedItems.map({ collectionNode.nodeForItem(at: $0) })
    cards.forEach({ card in
      guard let card = card as? BaseCardPostNode else {
        return
      }
      guard let indexPath = card.indexPath, let commonResource =  viewModel.resourceForIndex(for: activeSegment, index: indexPath.row) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = commonResource
    })
  }
  
  func updateCollection(with itemIndices: [IndexPath]? = nil, shouldReloadItems reloadItems: Bool = false, introductorySection: Bool = false, cardsSection: Bool = false, loaderSection: Bool = false, headerSection: Bool = false, orReloadAll reloadAll: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData(completion: {
        completionBlock?(true)
      })
    } else {
      collectionNode.performBatchUpdates({

        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if headerSection {
          collectionNode.reloadSections(IndexSet(integer: Section.header.rawValue))
        }
        if introductorySection {
          collectionNode.reloadSections(IndexSet(integer: Section.introductoryBanner.rawValue))
        }
        if cardsSection {
          collectionNode.reloadSections(IndexSet(integer: Section.cards.rawValue))
        } else if let itemIndices = itemIndices, itemIndices.count > 0 {
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

//MARK: - Localizable implementation
extension DiscoverViewController: Localizable {
  func applyLocalization() {
    navigationItem.title = Strings.discover()
    tabBarItem.title = Strings.discover().uppercased()

    let segments: [String] = self.segments.map({ $0.name })
    segmentedNode.initialize(with: segments)
    setupHeaderTitles()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()

    //Reload the Data upon language change
    _ = reloadViewData()
  }
}

// MARK: - Introductory Node Delegate
extension DiscoverViewController: IntroductoryBannerDelegate {
  func introductoryBannerDidTapDismissButton(_ introductoryBanner: IntroductoryBanner) {
    viewModel.shouldDisplayIntroductoryBanner = false
    updateCollection(introductorySection: true)
  }
}

// MARK: - Compose comment delegate implementation
extension DiscoverViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func commentComposerWillBeginPublishingComment(_ viewController: CommentComposerViewController) {
    SwiftLoader.show(animated: true)
  }
  
  func commentComposerDidFinishPublishingComment(_ viewController: CommentComposerViewController, success: Bool, comment: Comment?, resource: ModelCommonProperties?) {
    SwiftLoader.hide()
    
    if success {
      self.dismiss(animated: true, completion: nil)
    }
    
    if let resource = resource, let comment = comment {
      var topComments = resource.topComments ?? []
      topComments.append(comment)
      resource.topComments = topComments
      if let castedResource = resource as? ModelResource {
        DataManager.shared.update(resource: castedResource)
      }
    }
  }
}
