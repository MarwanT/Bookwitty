//
//  TopicViewController.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import GSImageViewerController
import SwiftLoader

enum TopicAction {
  case link
  case unlink
}

protocol TopicViewControllerDelegate: class {
  func topic(viewController: TopicViewController, didRequest action: TopicAction, for topic: Topic)
}

class TopicViewController: ASViewController<ASDisplayNode> {

  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case header = 0
    case relatedData
    case activityIndicator
  }
  
  enum NavigationItemMode {
    case view
    case action(TopicAction)
  }
  
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let segmentedNodeHeight: CGFloat = 45.0

  fileprivate let controllerNode: ASDisplayNode
  fileprivate let collectionNode: ASCollectionNode

  fileprivate var headerNode: TopicHeaderNode
  fileprivate var segmentedNode: SegmentedControlNode
  fileprivate let loaderNode: LoaderNode
  fileprivate var flowLayout: UICollectionViewFlowLayout

  fileprivate let actionBarNode: ActionBarNode

  fileprivate var normal: [Category] = [.latest(index: 0), .relatedBooks(index: 1), .followers(index: 2) ]
  fileprivate var book: [Category] = [.latest(index: 0), .editions(index: 1), .relatedBooks(index: 2), .followers(index: 3)]

  fileprivate lazy var mode: Mode = .normal(categories: self.normal)

  fileprivate let viewModel = TopicViewModel()

  fileprivate var loadingStatus: LoadingStatus = .none

  var navigationItemMode: NavigationItemMode = .view
  weak var delegate: TopicViewControllerDelegate?
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    headerNode = TopicHeaderNode()
    segmentedNode = SegmentedControlNode()
    loaderNode = LoaderNode()
    actionBarNode = ActionBarNode()

    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    controllerNode = ASDisplayNode()

    super.init(node: controllerNode)
    controllerNode.automaticallyManagesSubnodes = true

    controllerNode.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      self.collectionNode.style.maxSize = constrainedSize.max
      let wrapperLayoutSpec = ASWrapperLayoutSpec(layoutElement: self.collectionNode)
      let absoluteLayoutSpec = ASAbsoluteLayoutSpec(sizing: .default, children: [self.actionBarNode])
      let overlayLayoutSpec = ASOverlayLayoutSpec(child: wrapperLayoutSpec, overlay: absoluteLayoutSpec)
      return overlayLayoutSpec
    }
  }
  
  func initialize(with resource: ModelCommonProperties?) {
    viewModel.initialize(with: resource)
    self.mode = .normal(categories: self.normal)
    
    //MARK: [Analytics] Screen Name
    if let resourceType = viewModel.resourceType {
      switch resourceType {
      case Topic.resourceType, Author.resourceType:
        self.mode = .normal(categories: self.normal)
      case Book.resourceType:
        self.mode = .book(categories: self.book)
      default: break
      }
      
      switch resourceType {
      case Topic.resourceType:
        Analytics.shared.send(screenName: Analytics.ScreenNames.Topic)
      case Author.resourceType:
        Analytics.shared.send(screenName: Analytics.ScreenNames.Author)
      case Book.resourceType:
        Analytics.shared.send(screenName: Analytics.ScreenNames.TopicBook)
      default: break
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    loadNavigationBarButtons()

    applyLocalization()
    addObservers()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }

  private func initializeComponents() {
    headerNode.delegate = self

    segmentedNode.selectedSegmentChanged = segmentedNode(segmentedControlNode:didSelectSegmentIndex:)

    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true

    viewModel.callback = self.callback(for:)
  }
  
  private func loadNavigationBarButtons() {
  
    func setupShareNavigationItem() {
      let shareButton = UIBarButtonItem(
        image: #imageLiteral(resourceName: "shareOutside"),
        style: UIBarButtonItemStyle.plain,
        target: self,
        action: #selector(shareOutsideButton(_:)))
      navigationItem.rightBarButtonItem = shareButton
    }
    
    func setupRightNavigationItem(with action: TopicAction) {
      let title = action == .link ? Strings.link_topic() : Strings.unlink_topic()
      let actionButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(TopicViewController.linkUnlinkTouchUpInside(_ :)))
      navigationController?.navigationBar.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
      actionButton.setTitleTextAttributes([
        NSFontAttributeName: FontDynamicType.caption1.font,
        NSForegroundColorAttributeName : ThemeManager.shared.currentTheme.colorNumber19()], for: UIControlState.normal)
      

      navigationItem.rightBarButtonItem = actionButton
    }
    
    switch self.navigationItemMode {
    case .view:
      setupShareNavigationItem()
    case .action(let action):
      setupRightNavigationItem(with: action)
    }
  }

  fileprivate func fillHeaderNode() {
    let values = viewModel.valuesForHeader()

    headerNode.topicTitle = values.title
    headerNode.coverImageUrl = values.coverImageUrl
    headerNode.thumbnailImageUrl = values.thumbnailImageUrl
    headerNode.following = values.following

    headerNode.setTopicStatistics(numberOfFollowers: Int(values.stats.followers ?? ""), numberOfPosts: Int(values.stats.posts ?? ""))
    headerNode.setContributorsValues(numberOfContributors: values.contributors.count, imageUrls: values.contributors.imageUrls)
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {

    //MARK: [Analytics] Event
    let category = self.category(withIndex: index)
    loadData()

    var analyticsAction: Analytics.Action = .Default
    switch category {
    case .latest:
      analyticsAction = .GoToLatest
    case .editions:
      analyticsAction = .GoToEditions
    case .relatedBooks:
      analyticsAction = .GoToRelatedBooks
    case .followers:
      analyticsAction = .GoToFollowers
    default:
      break
    }

    var analyticsCategory: Analytics.Category = .Default
    if let resourceType = viewModel.resourceType {
      switch resourceType {
      case Topic.resourceType:
        analyticsCategory = .Topic
      case Author.resourceType:
        analyticsCategory = .Author
      case Book.resourceType:
        analyticsCategory = .TopicBook
      default:
        break
      }
    }
    let event: Analytics.Event = Analytics.Event(category: analyticsCategory,
                                                 action: analyticsAction)
    Analytics.shared.send(event: event)
  }

  private func callback(for callbackCategory: TopicViewModel.CallbackCategory) {
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch (callbackCategory, category) {
    case (.content, _):
      self.fillHeaderNode()
    case (.initialize, _):
      loadData()
    default:
      break
    }
  }
  
  func shareOutsideButton(_ sender: Any?) {
    guard let sharingContent = viewModel.externalySharedContent else {
      return
    }
    
    presentShareSheet(shareContent: sharingContent)
  }

  func linkUnlinkTouchUpInside(_ sender: UIBarButtonItem) {
    if let topic = self.viewModel.resource as? Topic {
      switch self.navigationItemMode {
      case .action(let action):
        self.delegate?.topic(viewController: self, didRequest: action, for: topic)

      default:
        break
      }
    }
  }
  
  func loadData() {
    setLoading(status: TopicViewController.LoadingStatus.loading)
    self.updateCollection(relatedDataSection: true, loaderSection: true)
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    viewModel.loadData(for: category) { (success, categoryForRequest) in
      if category.index == categoryForRequest.index {
        self.setLoading(status: TopicViewController.LoadingStatus.none)
        self.updateCollection(relatedDataSection: true, loaderSection: true)
      }
    }
  }
}

//MARK: - Notifications
extension TopicViewController {
  fileprivate func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
    
    observeLanguageChanges()
  }
  
  func updatedResources(_ notification: Notification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems.filter({ $0.section == Section.header.rawValue || $0.section == Section.relatedData.rawValue })

    let updateKey = DataManager.Notifications.Key.Update
    let deleteKey = DataManager.Notifications.Key.Delete

    guard let dictionary = notification.object as? [String : [String]] else {
        return
    }

    if let deletedIdentifiers = dictionary[deleteKey], deletedIdentifiers.count > 0 {
      if let resourceId = viewModel.resource?.id, deletedIdentifiers.contains(where: { $0 == resourceId }) {
        _ = self.navigationController?.popViewController(animated: true)
      } else {
        deletedIdentifiers.forEach({ viewModel.deleteResource(with: $0) })
        viewModel.updateResourceIfNeeded()
      }
    } else if let updatedIdentifiers = dictionary[updateKey], updatedIdentifiers.count > 0, visibleItemsIndexPaths.count > 0 {

      if let id = viewModel.resource?.id {
        let found = updatedIdentifiers.contains(id)
        if found {
          viewModel.updateResourceIfNeeded()
        }
      }

      var indexPathForAffectedItems = visibleItemsIndexPaths.filter({
        indexPath in
        guard let resourceIdentifier = resourceIdentifierForIndex(indexPath: indexPath) else {
          return false
        }
        return updatedIdentifiers.contains(resourceIdentifier)
      })

      if let index = indexPathForAffectedItems.index(where: { $0.section == Section.header.rawValue }) {
        //Note: Fill Header manually and remove index from indexPathForAffectedItems to bypass auto-reload-collection-animation issue
        self.fillHeaderNode()
        indexPathForAffectedItems.remove(at: index)
      }
      if indexPathForAffectedItems.count > 0 {
        updateCollectionNodes(indexPathForAffectedItems: indexPathForAffectedItems)
      }
    }
  }
  
  func resourceIdentifierForIndex(indexPath: IndexPath) -> String? {
    if indexPath.section == Section.header.rawValue {
      let values = viewModel.valuesForHeader()
      return values.identifier
    } else if indexPath.section == Section.relatedData.rawValue {
      let category = self.category(withIndex: segmentedNode.selectedIndex)
      switch category {
      case .latest:
        let values = viewModel.valuesForLatest(at: indexPath.item)
        return values?.identifier
      case .editions:
        let values = viewModel.valuesForEdition(at: indexPath.item)
        return values?.identifier
      case .relatedBooks:
        let values = viewModel.valuesForRelatedBook(at: indexPath.item)
        return values?.identifier
      case .followers:
        let values = viewModel.valuesForFollower(at: indexPath.item)
        return values?.identifier
      case .none:
        return nil
      }
    }
    return nil
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

  enum Category {
    case latest(index: Int)
    case relatedBooks(index: Int)
    case editions(index: Int)
    case followers(index: Int)
    case none

    var name: String {
      switch self {
      case .latest:
        return Strings.latest()
      case .relatedBooks:
        return Strings.related_books()
      case .editions:
        return Strings.editions()
      case .followers:
        return Strings.followers()
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

//MARK: - Loading Status Helper
extension TopicViewController {
  func setLoading(status: LoadingStatus) {
    self.loadingStatus = status
  }
}

extension TopicViewController: TopicHeaderNodeDelegate {
  func topicHeader(node: TopicHeaderNode, actionButtonTouchUpInside button: ButtonWithLoader) {
    button.state = .loading
    if button.isSelected {
      viewModel.unfollowContent(completionBlock: { (success: Bool) in
        if success {
          node.following = false
        }
        button.state = success ? .normal : .selected
      })
    } else {
      viewModel.followContent(completionBlock: { (success: Bool) in
        if success {
          node.following = true
        }
        button.state = success ? .selected : .normal
      })
    }

    //MARK: [Analytics] Event
    var analyticsAction: Analytics.Action = .Default
    var analyticsCategory: Analytics.Category = .Default
    if let resourceType = viewModel.resourceType {
      switch resourceType {
      case Topic.resourceType:
        analyticsCategory = .Topic
        analyticsAction = button.isSelected ? .UnfollowTopic : .FollowTopic
      case Author.resourceType:
        analyticsCategory = .Author
        analyticsAction = button.isSelected ? .UnfollowAuthor : .FollowAuthor
      case Book.resourceType:
        analyticsCategory = .TopicBook
        analyticsAction = button.isSelected ? .UnfollowTopicBook : .FollowTopicBook
      default:
        break
      }
    }

    let name = viewModel.valuesForHeader().title ?? ""
    let event: Analytics.Event = Analytics.Event(category: analyticsCategory,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func topicHeader(node: TopicHeaderNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
    let transitionInfo = GSTransitionInfo(fromView: imageNode.view)
    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
    present(imageViewer, animated: true, completion: nil)
  }
}

extension TopicViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    penName(node: node, actionPenNameFollowTouchUpInside: imageNode)
  }

  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }
    button.state = .loading
    if button.isSelected {
      viewModel.unfollowPenName(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = !success
        button.state = success ? .normal : .selected
      })
    } else {
      viewModel.followPenName(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = success
        button.state = success ? .selected : .normal
      })
    }
  }

  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let penName = viewModel.follower(at: indexPath.row) else {
        return
    }
    pushProfileViewController(penName: penName)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                 action: .GoToDetails,
                                                 name: penName.name ?? "")
    Analytics.shared.send(event: event)
  }

  func penName(node: PenNameFollowNode, moreButtonTouchUpInside button: ASButtonNode?) {
    
    guard let indexPath = collectionNode.indexPath(for: node),
      let resource = viewModel.follower(at: indexPath.row),
      let identifier = resource.id else {
        return
    }

    let actions: [MoreAction] = MoreAction.actions(for: resource as? ModelCommonProperties)
    self.showMoreActionSheet(identifier: identifier, actions: actions, completion: {
      (success: Bool, action: MoreAction) in

    })
  }
}


//MARK: - UICollectionViewDelegateFlowLayout implementation
extension TopicViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section != Section.relatedData.rawValue ? CGSize.zero : CGSize(width: collectionView.frame.size.width, height: segmentedNodeHeight)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    guard section == Section.relatedData.rawValue else {
      return UIEdgeInsets.zero
    }

    return UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0.0, right: 0.0)
  }
}

extension TopicViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 3
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {

    if section == Section.header.rawValue {
      return 1
    }

    if section == Section.activityIndicator.rawValue {
      return loadingStatus != .none ? 1 : 0
    }

    var contentNumberOfRows: Int

    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      contentNumberOfRows = viewModel.numberOfLatest()
    case .editions:
      contentNumberOfRows = viewModel.numberOfEditions()
    case .relatedBooks:
      contentNumberOfRows = viewModel.numberOfRelatedBooks()
    case .followers:
      contentNumberOfRows = viewModel.numberOfFollowers()
    case .none:
      contentNumberOfRows = 0
    }

    return contentNumberOfRows
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    if indexPath.section == Section.header.rawValue {
      return {
        return self.headerNode
      }
    }

    if indexPath.section == Section.activityIndicator.rawValue {
      return {
        return self.loaderNode
      }
    }

    return {
      return self.cellNodeBlockFor(indexPath: indexPath, category: self.category(withIndex: self.segmentedNode.selectedIndex))
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    guard indexPath.section == Section.relatedData.rawValue else {
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
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }
    if indexPath.section == Section.activityIndicator.rawValue {
      self.loaderNode.updateLoaderVisibility(show: self.loadingStatus != .none)
    }
    else if indexPath.section == Section.header.rawValue {
      self.fillHeaderNode()
    } else if indexPath.section == Section.relatedData.rawValue {
      _ = loadDataForCategory(node: node, indexPath: indexPath)
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  private func cellNodeBlockFor(indexPath: IndexPath, category: Category) -> ASCellNode {
    let item = indexPath.item

    switch category {
    case .latest:
      guard let post = viewModel.latest(at: item),
        let node = CardFactory.createCardFor(resourceType: post.registeredResourceType) else {
        return ASCellNode()
      }
      node.baseViewModel?.resource = post as? ModelCommonProperties
      // Fetch the reading list cards images
      if let readingListCell = node as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(at: item, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.prepareImages(imageCount: imageCollection.count)
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
      } else if let bookCard = node as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: post , section: BookTypeRegistry.Section.topicLatest) ?? .topic == .product)
      }

      node.delegate = self
      return node
    case .editions:
      fallthrough
    case .relatedBooks:
      let node = BookNode()
      loadDataForCategory(node: node, indexPath: indexPath)
      return node
    case .followers:
      let node = PenNameFollowNode()
      loadDataForCategory(node: node, indexPath: indexPath)
      node.showBottomSeparator = true
      node.delegate = self
      return node
    case .none:
      return ASCellNode()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == 1 else {
      return
    }

    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      let resource = viewModel.latest(at: indexPath.item)
      actionForCard(resource: resource)
    case .relatedBooks:
      //TODO: [DataManager]
      if let resource = viewModel.relatedBook(at: indexPath.item) {
        guard !resource.isPandacraft else {
          if let url = resource.canonicalURL {
            WebViewController.present(url: url)
          }
          return
        }
        let vc = BookDetailsViewController()
        vc.initialize(with: resource)
        navigationController?.pushViewController(vc, animated: true)
      }
    case .editions:
      //TODO: [DataManager]
      if let resource = viewModel.edition(at: indexPath.item) {
        guard !resource.isPandacraft else {
          if let url = resource.canonicalURL {
            WebViewController.present(url: url)
          }
          return
        }
        let vc = BookDetailsViewController()
        vc.initialize(with: resource)
        navigationController?.pushViewController(vc, animated: true)
      }
    case .followers:
      break
    case .none:
      break
    }
  }

  func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      return viewModel.hasNextLatest
    case .relatedBooks:
      return viewModel.hasNextRelatedBooks
    case .editions:
      return viewModel.hasNextEditions
    case .followers:
      return viewModel.hasNextFollowers
    case .none:
      return false
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }
    guard loadingStatus == .none else {
      context.completeBatchFetching(true)
      return
    }

    context.beginBatchFetching()
    self.setLoading(status: .loadMore)
    DispatchQueue.main.sync {
      self.updateCollection(loaderSection: true)
    }

    var callBackCategory: TopicViewModel.CallbackCategory = .content
    let category = self.category(withIndex: segmentedNode.selectedIndex)

    switch category {
    case .latest:
      callBackCategory = .latest
    case .editions:
      callBackCategory = .editions
    case .relatedBooks:
      callBackCategory = .relatedBooks
    case .followers:
      callBackCategory = .followers
    default:
      break
    }

    viewModel.loadNext(for: callBackCategory) {
      (success: Bool, indices: [Int]?, callBackCategory) in
      var insert: Bool = false
      var indexes: [IndexPath]?
      defer {
        context.completeBatchFetching(true)
        if category.index != self.category(withIndex: self.segmentedNode.selectedIndex).index {
          self.updateCollection( relatedDataSection: true, loaderSection: true)
        } else if let indexes = indexes {
          self.setLoading(status: .none)
          self.updateCollection(with: indexes, shouldReloadItems: false, loaderSection: true)
        } else {
          self.setLoading(status: .none)
          self.updateCollection(loaderSection: true)
        }
      }

      if success {
        switch callBackCategory {
        case .latest, .editions, .relatedBooks, .followers:
          insert = true
        default:
          insert = false
        }

        if insert {
          indexes = indices?.map({ IndexPath(item: $0, section: 1) }) ?? []
        }
      }
    }
  }

  private func loadDataForCategory(node: ASCellNode, indexPath: IndexPath) {
    let category = self.category(withIndex: segmentedNode.selectedIndex)

    switch category {
    case .latest:
      guard let post = viewModel.latest(at: indexPath.row),
        let card = node as? BaseCardPostNode else {
          return
      }

      if let commonResource = post as? ModelCommonProperties,
        let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }

      if let bookCard = card as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: post , section: BookTypeRegistry.Section.topicLatest) ?? .topic == .product)
      }
    case .editions:
      guard let cell = node as? BookNode else {
        return
      }

      let bookValues = viewModel.valuesForEdition(at: indexPath.item)
      cell.title = bookValues?.title
      cell.author = bookValues?.author
      cell.format = bookValues?.format
      cell.price = bookValues?.price
      cell.imageUrl = bookValues?.imageUrl
    case .relatedBooks:
      guard let cell = node as? BookNode else {
        return
      }

      let bookValues = viewModel.valuesForRelatedBook(at: indexPath.item)
      cell.title = bookValues?.title
      cell.author = bookValues?.author
      cell.format = bookValues?.format
      cell.price = bookValues?.price
      cell.imageUrl = bookValues?.imageUrl
    case .followers:
      guard let cell = node as? PenNameFollowNode else {
        return
      }

      let followerValues = viewModel.valuesForFollower(at: indexPath.item)
      cell.penName = followerValues?.penName
      cell.biography = followerValues?.biography
      cell.imageUrl = followerValues?.imageUrl
      cell.following = followerValues?.following ?? false
      cell.showMoreButton = !(followerValues?.isMyPenName ?? false)
      cell.updateMode(disabled: followerValues?.isMyPenName ?? false)
    case .none:
      break
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension TopicViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at indexPath: IndexPath) {
    let index: Int = indexPath.row
    var resource: ModelResource?
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      resource = viewModel.latest(at: index)
    case .editions:
      resource = viewModel.edition(at: index)
    case .relatedBooks:
      resource = viewModel.relatedBook(at: index)
    case .followers:
      resource = viewModel.follower(at: index)
    case .none:
      return
    }

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

    let index: Int = indexPath.row
    var candidateResource: ModelResource?
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      candidateResource = viewModel.latest(at: index)
    case .editions:
      candidateResource = viewModel.edition(at: index)
    case .relatedBooks:
      candidateResource = viewModel.relatedBook(at: index)
    case .followers:
      candidateResource = viewModel.follower(at: index)
    case .none:
      return
    }

    guard let resource = candidateResource else {
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
      didFinishAction?(false)
      return
    }
    let index: Int = indexPath.row
    var candidateResource: ModelResource?
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      candidateResource = viewModel.latest(at: index)
    case .editions:
      candidateResource = viewModel.edition(at: index)
    case .relatedBooks:
      candidateResource = viewModel.relatedBook(at: index)
    case .followers:
      candidateResource = viewModel.follower(at: index)
    case .none:
      return
    }
    guard let resource = candidateResource else {
      didFinishAction?(false)
      return
    }

    switch(action) {
    case .wit:
      viewModel.witContent(contentId: resource.id) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(contentId: resource.id) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(resource: resource) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow(resource: resource) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(resource: resource) { (success) in
        didFinishAction?(success)
      }
    case .comment:      
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = resource as? ModelCommonProperties,
        let identifier = resource.id else { return }

      let actions: [MoreAction] = MoreAction.actions(for: resource as? ModelCommonProperties)
      self.showMoreActionSheet(identifier: identifier, actions: actions, completion: { (success: Bool, action: MoreAction) in
        didFinishAction?(success)
      })
    default:
      break
    }

    //MARK: [Analytics] Event
    let analyticsCategory: Analytics.Category
    var name: String = (resource as? ModelCommonProperties)?.title ?? ""
    switch resource.registeredResourceType {
    case Image.resourceType:
      analyticsCategory = .Image
    case Quote.resourceType:
      analyticsCategory = .Quote
    case Video.resourceType:
      analyticsCategory = .Video
    case Audio.resourceType:
      analyticsCategory = .Audio
    case Link.resourceType:
      analyticsCategory = .Link
    case Author.resourceType:
      analyticsCategory = .Author
      name = (resource as? Author)?.name ?? ""
    case ReadingList.resourceType:
      analyticsCategory = .ReadingList
    case Topic.resourceType:
      analyticsCategory = .Topic
    case Text.resourceType:
      analyticsCategory = .Text
    case Book.resourceType:
      analyticsCategory = .TopicBook
    case PenName.resourceType:
      analyticsCategory = .PenName
      name = (resource as? PenName)?.name ?? ""
    default:
      analyticsCategory = .Default
    }

    let analyticsAction = Analytics.Action.actionFrom(cardAction: action, with: analyticsCategory)
    let event: Analytics.Event = Analytics.Event(category: analyticsCategory,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
  
  func cardNode(card: BaseCardPostNode, didRequestAction action: BaseCardPostNode.Action, from: ASDisplayNode) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
        return
    }

    let index: Int = indexPath.row
    var candidateResource: ModelResource?
    let category = self.category(withIndex: segmentedNode.selectedIndex)
    switch category {
    case .latest:
      candidateResource = viewModel.latest(at: index)
    case .editions:
      candidateResource = viewModel.edition(at: index)
    case .relatedBooks:
      candidateResource = viewModel.relatedBook(at: index)
    case .followers:
      candidateResource = viewModel.follower(at: index)
    case .none:
      return
    }

    guard let resource = candidateResource as? ModelCommonProperties else {
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
    let analyticsCategory: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      analyticsCategory = .Image
    case Quote.resourceType:
      analyticsCategory = .Quote
    case Video.resourceType:
      analyticsCategory = .Video
    case Audio.resourceType:
      analyticsCategory = .Audio
    case Link.resourceType:
      analyticsCategory = .Link
    case Author.resourceType:
      analyticsCategory = .Author
    case ReadingList.resourceType:
      analyticsCategory = .ReadingList
    case Topic.resourceType:
      analyticsCategory = .Topic
    case Text.resourceType:
      analyticsCategory = .Text
    case Book.resourceType:
      analyticsCategory = .TopicBook
    case PenName.resourceType:
      analyticsCategory = .PenName
    default:
      analyticsCategory = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: analyticsCategory,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int) {
    //Empty Implementation
  }
}

// MARK: - Actions For Cards
extension TopicViewController {
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

  func pushPostDetailsViewController(resource: ModelResource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  func pushGenericViewControllerCard(resource: ModelResource, title: String? = nil) {
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

    let isProduct = (viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.topicLatest) ?? .topic == .product)

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
      guard !resource.isPandacraft else {
        if let url = resource.canonicalURL {
          WebViewController.present(url: url)
        }
        return
      }
      let bookDetailsViewController = BookDetailsViewController()
      bookDetailsViewController.initialize(with: resource)
      navigationController?.pushViewController(bookDetailsViewController, animated: true)
    }
  }
}

//MARK: - Localizable implementation
extension TopicViewController: Localizable {
  func applyLocalization() {
    headerNode = TopicHeaderNode()
    headerNode.delegate = self

    let segments: [String] = self.mode.categories.map({ $0.name })
    segmentedNode.initialize(with: segments)

    updateCollection(orReloadAll: true)
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

extension TopicViewController {
  func updateCollectionNodes(indexPathForAffectedItems: [IndexPath]) {
    let cards = indexPathForAffectedItems.map({ collectionNode.nodeForItem(at: $0) })
    cards.forEach({ card in
      guard let card = card as? BaseCardPostNode else {
        return
      }

      guard let indexPath = card.indexPath, let resourceId = resourceIdentifierForIndex(indexPath: indexPath),
        let commonResource =  DataManager.shared.fetchResource(with: resourceId) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = commonResource
    })
  }

  func updateCollection(with itemIndices: [IndexPath]? = nil, shouldReloadItems reloadItems: Bool = false, relatedDataSection: Bool = false, loaderSection: Bool = false, orReloadAll reloadAll: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData(completion: {
        completionBlock?(true)
      })
    } else {
      collectionNode.performBatch(animated: false, updates: {
        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if relatedDataSection {
          collectionNode.reloadSections(IndexSet(integer: Section.relatedData.rawValue))
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

// MARK: - Compose comment delegate implementation
extension TopicViewController: CommentComposerViewControllerDelegate {
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
