//
//  SearchViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SwiftLoader

class SearchViewController: ASViewController<ASCollectionNode> {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }
  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let loaderNode: LoaderNode
  let misfortuneNode: MisfortuneNode
  let filterNode: FilterCellNode

  var searchBar: UISearchBar?
  var viewModel: SearchViewModel = SearchViewModel()
  var loadingStatus: LoadingStatus = .none {
    didSet {
      var showLoader: Bool = false
      switch (loadingStatus) {
      case .none:
        showLoader = true
      default:
        showLoader = false
      }
      loaderNode.updateLoaderVisibility(show: showLoader)
    }
  }
  var shouldShowLoader: Bool {
    return (loadingStatus != .none)
  }
  var shouldDisplayMisfortuneNode: Bool {
    guard let misfortuneMode = viewModel.misfortuneNodeMode, !shouldShowLoader else {
      return false
    }
    misfortuneNode.mode = misfortuneMode
    return true
  }

  var shouldDisplayFilter: Bool {
    guard let facet = viewModel.facet else {
      return false
    }
    let categories = facet.categories?.count ?? 0 > 0
    let languages = facet.languages?.count ?? 0 > 0
    let types = facet.types?.count ?? 0 > 0

    let containsFilter: Bool = (viewModel.filter.categories.count > 0 || viewModel.filter.languages.count > 0 || viewModel.filter.types.count > 0)

    return categories || languages || types || containsFilter
  }

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
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
    misfortuneNode.style.height = ASDimensionMake(0)
    misfortuneNode.style.width = ASDimensionMake(0)

    filterNode = FilterCellNode()
    filterNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    super.init(node: collectionNode)
    
    misfortuneNode.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
    collectionNode.dataSource = self
    collectionNode.delegate = self
    configureSearchController()
    searchBar?.becomeFirstResponder()

    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)

    applyLocalization()
    observeLanguageChanges()

    addObservers()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Search)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    misfortuneNode.style.height = ASDimensionMake(collectionNode.frame.height)
    misfortuneNode.style.width = ASDimensionMake(collectionNode.frame.width)
    misfortuneNode.setNeedsLayout()
  }

  func dismissKeyboard() {
    view.endEditing(true)
    searchBar?.resignFirstResponder()
  }

  func configureSearchController() {
    let navHeight: CGFloat = navigationController?.navigationBar.frame.size.height ?? 0.0
    let sideMargin: CGFloat = 50.0
    let size: CGSize = CGSize(width: UIScreen.main.bounds.width - sideMargin, height: navHeight)

    searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
    searchBar?.placeholder = Strings.search_placeholder()
    searchBar?.delegate = self
    searchBar?.showsCancelButton = false
    searchBar?.sizeToFit()

    searchBar?.setTextColor(color: ThemeManager.shared.currentTheme.defaultTextColor())
    searchBar?.setTextFieldColor(color: ThemeManager.shared.currentTheme.colorNumber18().withAlphaComponent(0.7))
    searchBar?.setPlaceholderTextColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    searchBar?.setSearchImageColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    searchBar?.setTextFieldClearButtonColor(color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())

    if let searchBar = searchBar {
      let leftNavBarButton = UIBarButtonItem(customView: searchBar)
      self.navigationItem.rightBarButtonItem = leftNavBarButton
    }
  }

  fileprivate func searchAction() {
    loadingStatus = .loading
    viewModel.clearSearchData()
    updateCollection(reloadAll: true)

    let query = viewModel.filter.query ?? ""
    viewModel.search(query: query) { (success, error) in
      self.loadingStatus = .none
      self.updateCollection(with: nil, loaderSection: true, dataSection: true)
    }

    let filtersInfo = viewModel.filterDictionary()
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Search,
                                                 action: .SearchOnBookwitty,
                                                 name: query,
                                                 info: filtersInfo)
    Analytics.shared.send(event: event)
  }


  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
  }


  @objc
  private func updatedResources(_ notification: NSNotification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems

    guard let identifiers = notification.object as? [String],
      identifiers.count > 0,
      visibleItemsIndexPaths.count > 0 else {
        return
    }

    let indexPathForAffectedItems = viewModel.indexPathForAffectedItems(resourcesIdentifiers: identifiers, visibleItemsIndexPaths: visibleItemsIndexPaths)
    updateCollectionNodes(indexPathForAffectedItems: indexPathForAffectedItems)
  }

  fileprivate func pushFilterViewController() {
    guard let facet = viewModel.facet else {
      return
    }

    if facet.categories?.count == 0 && viewModel.filter.categories.count > 0 {
      facet.categories = viewModel.filter.categories
    }

    if facet.languages?.count == 0 && viewModel.filter.languages.count > 0 {
      facet.languages = viewModel.filter.languages
    }

    if facet.types?.count == 0 && viewModel.filter.types.count > 0 {
      facet.types = viewModel.filter.types
    }

    let searchFiltersViewController = Storyboard.Misc.instantiate(SearchFiltersViewController.self)
    searchFiltersViewController.viewModel.initialize(with: facet, and: viewModel.filter)
    searchFiltersViewController.delegate = self
    self.navigationController?.pushViewController(searchFiltersViewController, animated: true)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Search,
                                                 action: .GoToFilters)
    Analytics.shared.send(event: event)
  }
}

extension SearchViewController: Themeable {
  func applyTheme() {
   collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension SearchViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    if section == Section.filter.rawValue {
      return shouldDisplayFilter ? 1 : 0
    } else if section == Section.activityIndicator.rawValue {
      return shouldShowLoader ? 1 : 0
    } else if section == Section.misfortune.rawValue {
      return shouldDisplayMisfortuneNode ? 1 : 0
    } else {
      return viewModel.numberOfItemsInSection(section: section)
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let indexPath = indexPath

    return {

      if indexPath.section == Section.filter.rawValue {
        return self.filterNode
      } else if indexPath.section == Section.activityIndicator.rawValue {
        //Return the activity indicator
        return self.loaderNode
      } else if indexPath.section == Section.misfortune.rawValue {
        return self.misfortuneNode
      } else {
        let baseCardNode = self.viewModel.nodeForItem(atIndexPath: indexPath) ?? BaseCardPostNode()
        if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
          !readingListCell.node.isImageCollectionLoaded {
          let max = readingListCell.node.maxNumberOfImages
          self.viewModel.loadReadingListImages(atIndexPath: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
            if let imageCollection = imageCollection, imageCollection.count > 0 {
              readingListCell.node.prepareImages(imageCount: imageCollection.count)
              readingListCell.node.loadImages(with: imageCollection)
            }
          })
        } else if let bookCard = baseCardNode as? BookCardPostCellNode, let resource = self.viewModel.resourceForIndex(indexPath: indexPath) {
            bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.search) ?? .topic == .product)
        }
        baseCardNode.delegate = self
        return baseCardNode
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: !(loadingStatus == .none))
    } else if node is MisfortuneNode {
      misfortuneNode.mode = viewModel.misfortuneNodeMode ?? MisfortuneNode.Mode.empty
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(indexPath: indexPath), let commonResource =  resource as? ModelCommonProperties else {
          return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }

      if let bookCard = card as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.search) ?? .topic == .product)
      }
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension SearchViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(indexPath: indexPath)
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
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath) else {
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
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }

    switch(action) {
    case .wit:
      viewModel.witContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(indexPath: indexPath) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .comment:
      guard let resource = viewModel.resourceForIndex(indexPath: indexPath) else { return }
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = viewModel.resourceForIndex(indexPath: indexPath),
        let identifier = resource.id else { return }
      self.showMoreActionSheet(identifier: identifier, actions: [.report(.content)], completion: { (success: Bool) in
        didFinishAction?(success)
      })
    default:
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath) else { return }
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
      let resource = viewModel.resourceForIndex(indexPath: indexPath),
      let postId = resource.id else {
        return
    }

    let analyticsAction: Analytics.Action
    switch(action) {
    case .listComments:
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      analyticsAction = .ViewTopComment
    case .publishComment:
      CommentComposerViewController.show(from: self, delegate: self, postId: postId, parentCommentId: nil)
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

    let name: String = (resource as? ModelCommonProperties)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int) {
    //Empty Implementation
  }
}

extension SearchViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {

    if indexPath.section == Section.filter.rawValue {
      pushFilterViewController()
      return
    }

    let resource = viewModel.resourceForIndex(indexPath: indexPath)
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
      self.updateCollection(with: nil, loaderSection: true, dataSection: false)
    }

    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cards.rawValue)

    //MARK: [Analytics] Event
    let query = searchBar?.text ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Search,
                                                 action: .LoadMore,
                                                 name: query)
    Analytics.shared.send(event: event)

    // Fetch next page data
    viewModel.loadNextPage { [weak self] (success) in
      var updatedIndexPathRange: [IndexPath]? = nil
      defer {
        self?.loadingStatus = .none
        self?.updateCollection(with: updatedIndexPathRange, loaderSection: true, completionBlock: nil)
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

extension SearchViewController {
  func updateCollectionNodes(indexPathForAffectedItems: [IndexPath]) {
    let cards = indexPathForAffectedItems.map({ collectionNode.nodeForItem(at: $0) })
    cards.forEach({ card in
      guard let card = card as? BaseCardPostNode else {
        return
      }
      guard let indexPath = card.indexPath, let commonResource =  viewModel.resourceForIndex(indexPath: indexPath) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = commonResource
    })
  }

  func updateCollection(reloadAll: Bool = false, with itemIndices: [IndexPath]? = nil, reloadItemsWithIndices: Bool = false, loaderSection: Bool = false, dataSection: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData()
    } else {
      collectionNode.performBatchUpdates({
        // Always relaod misfortune section
        collectionNode.reloadSections(IndexSet(integer: Section.misfortune.rawValue))
        collectionNode.reloadSections(IndexSet(integer: Section.filter.rawValue))

        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if dataSection {
          collectionNode.reloadSections(IndexSet(integer: Section.cards.rawValue))
        } else if let itemIndices = itemIndices {
          if reloadItemsWithIndices {
            collectionNode.reloadItems(at: itemIndices)
          } else {
            collectionNode.insertItems(at: itemIndices)
          }
        }
      }, completion: completionBlock)
    }
  }
}

//MARK: - SearchFiltersViewControllerDelegate implementation
extension SearchViewController: SearchFiltersViewControllerDelegate {
  func searchFilter(viewController: SearchFiltersViewController, didSelect filter: Filter) {
    _ = viewController.navigationController?.popViewController(animated: true)
    viewModel.filter = filter
    searchAction()
  }
}

extension SearchViewController: UISearchBarDelegate {
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    return true
  }

  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }

  public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    if viewModel.filter.query != searchBar.text {
      searchBar.text = viewModel.filter.query
    }
    return true
  }

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    /* Discussion:
     * Reset the filters when the query is new
     */
    if viewModel.filter.query != searchBar.text {
      viewModel.filter.query = searchBar.text
      viewModel.filter.categories.removeAll()
      viewModel.filter.languages.removeAll()
      viewModel.filter.types.removeAll()
    }
    searchAction()
    searchBar.resignFirstResponder()
  }

  public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = viewModel.filter.query
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
  }
}
// MARK: - Actions For Cards
extension SearchViewController {

  fileprivate func actionForCard(resource: ModelResource?) {
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

  fileprivate func pushPostDetailsViewController(resource: ModelResource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  fileprivate func pushGenericViewControllerCard(resource: ModelResource, title: String? = nil) {
    guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
      return
    }
    
    cardNode.baseViewModel?.resource = resource as? ModelCommonProperties
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
    let event: Analytics.Event = Analytics.Event(category: .Author,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
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
    let isProduct = (viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.search) ?? .topic == .product)
    //MARK: [Analytics] Event
    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: isProduct ? .BookProduct : .TopicBook,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    if !isProduct {
      let topicViewController = TopicViewController()
      topicViewController.initialize(with: resource as ModelCommonProperties)
      navigationController?.pushViewController(topicViewController, animated: true)
    } else {
      let bookDetailsViewController = BookDetailsViewController()
      bookDetailsViewController.initialize(with: resource)
      navigationController?.pushViewController(bookDetailsViewController, animated: true)
    }
  }
}


// MARK: - Declarations
extension SearchViewController {
  enum Section: Int {
    case filter = 0
    case cards = 1
    case activityIndicator
    case misfortune

    static var numberOfSections: Int {
      return 4
    }
  }
}

//MARK: - Localizable implementation
extension SearchViewController: Localizable {
  func applyLocalization() {
    searchBar?.placeholder = Strings.search_placeholder()
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = Strings.cancel()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

// MARK: - Misfortune node delegate
extension SearchViewController: MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?) {
    guard let action = action else {
      return
    }
    
    switch action {
    case .tryAgain:
      searchAction()
    case .settings:
      AppDelegate.openSettings()
    default:
      break
    }
  }
}


// MARK: - Compose comment delegate implementation
extension SearchViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }

  func commentComposerPublish(_ viewController: CommentComposerViewController, content: String?, postId: String?, parentCommentId: String?) {
    guard let postId = postId else {
      _ = viewController.becomeFirstResponder()
      return
    }

    SwiftLoader.show(animated: true)
    let commentManager = CommentsManager()
    commentManager.initialize(postIdentifier: postId)
    commentManager.publishComment(content: content, parentCommentId: nil) {
      (success: Bool, comment: Comment?, error: CommentsManager.Error?) in
      SwiftLoader.hide()
      guard success else {
        guard let error = error else { return }
        self.showAlertWith(title: error.title ?? "", message: error.message ?? "", handler: {
          _ in
          _ = viewController.becomeFirstResponder()
        })
        return
      }

      if let resource = DataManager.shared.fetchResource(with: postId), let comment = comment {
        var topComments = (resource as? ModelCommonProperties)?.topComments ?? []
        topComments.append(comment)
        (resource as? ModelCommonProperties)?.topComments = topComments
        DataManager.shared.update(resource: resource)
      }

      self.dismiss(animated: true, completion: nil)
    }
    dismiss(animated: true, completion: nil)
  }
}
