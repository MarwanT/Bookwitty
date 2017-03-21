//
//  TopicViewController.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicViewController: ASViewController<ASCollectionNode> {

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

  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let segmentedNodeHeight: CGFloat = 45.0

  fileprivate let collectionNode: ASCollectionNode

  fileprivate var headerNode: TopicHeaderNode
  fileprivate var segmentedNode: SegmentedControlNode
  fileprivate let loaderNode: LoaderNode
  fileprivate var flowLayout: UICollectionViewFlowLayout

  fileprivate var normal: [Category] = [.latest(index: 0), .relatedBooks(index: 1), .followers(index: 2) ]
  fileprivate var book: [Category] = [.latest(index: 0), .relatedBooks(index: 1), .editions(index: 2), .followers(index: 3)]

  fileprivate lazy var mode: Mode = .normal(categories: self.normal)

  fileprivate let viewModel = TopicViewModel()

  fileprivate var loadingStatus: LoadingStatus = .none


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    headerNode = TopicHeaderNode()
    segmentedNode = SegmentedControlNode()
    loaderNode = LoaderNode()

    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  func initialize(withTopic topic: Topic?) {
    viewModel.initialize(withTopic: topic)
    self.mode = .normal(categories: self.normal)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Topic)
  }

  func initialize(withBook book: Book?) {
    viewModel.initialize(withBook: book)
    self.mode = .normal(categories: self.book)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.TopicBook)
  }

  func initialize(withAuthor author: Author?) {
    viewModel.initialize(withAuthor: author)
    self.mode = .normal(categories: self.normal)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Author)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    loadNavigationBarButtons()
  }

  private func initializeComponents() {
    title = Strings.topic()

    headerNode.delegate = self

    let segments: [String] = self.mode.categories.map({ $0.name })
    segmentedNode.initialize(with: segments)

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
    let shareButton = UIBarButtonItem(
      image: #imageLiteral(resourceName: "shareOutside"),
      style: UIBarButtonItemStyle.plain,
      target: self,
      action: #selector(shareOutsideButton(_:)))
    navigationItem.rightBarButtonItem = shareButton
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
    collectionNode.reloadSections(IndexSet(integer: 1))

    //MARK: [Analytics] Event
    let category = self.category(withIndex: index)
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
      self.collectionNode.reloadSections(IndexSet(integer: Section.header.rawValue))
    case (.latest, .latest): fallthrough
    case (.editions, .editions): fallthrough
    case (.relatedBooks, .relatedBooks): fallthrough
    case (.followers, .editions):
      self.collectionNode.reloadSections(IndexSet(integer: Section.relatedData.rawValue))
    default:
      break
    }
  }
  
  func shareOutsideButton(_ sender: Any?) {
    guard let sharingContent = viewModel.externalySharedContent else {
      return
    }
    
    let activityViewController = UIActivityViewController(
      activityItems: sharingContent,
      applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
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

  fileprivate enum Category {
    case latest(index: Int)
    case relatedBooks(index: Int)
    case editions(index: Int)
    case followers(index: Int)
    case none

    //TODO: Should be localized
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

    let show: Bool
    switch self.loadingStatus {
    case .loading, .loadMore, .reloading:
      show = true
    case .none:
      show = false
    }

    if Thread.current.isMainThread {
      self.loaderNode.updateLoaderVisibility(show: show)
      self.collectionNode.reloadSections(IndexSet(integer: 2))
    } else {
      DispatchQueue.main.sync {
        self.loaderNode.updateLoaderVisibility(show: show)
        self.collectionNode.reloadSections(IndexSet(integer: 2))
      }
    }
  }
}

extension TopicViewController: TopicHeaderNodeDelegate {
  func topicHeader(node: TopicHeaderNode, actionButtonTouchUpInside button: ASButtonNode) {
    if button.isSelected {
      viewModel.unfollowContent(completionBlock: { (success: Bool) in
        if success {
          node.following = false
          button.isSelected = false
        }
      })
    } else {
      viewModel.followContent(completionBlock: { (success: Bool) in
        if success {
          node.following = true
          button.isSelected = true
        }
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
}

extension TopicViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ASButtonNode) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }

    if button.isSelected {
      viewModel.unfollowPenName(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = false
        button.isSelected = false
      })
    } else {
      viewModel.followPenName(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = true
        button.isSelected = true
      })
    }
  }

  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let penName = viewModel.follower(at: indexPath.row) else {
        return
    }
    pushProfileViewController(penName: penName)
  }
}


extension TopicViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section != Section.relatedData.rawValue ? CGSize.zero : CGSize(width: collectionView.frame.size.width, height: segmentedNodeHeight)
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
      return self.cellNodeBlockFor(item: indexPath.item, category: self.category(withIndex: self.segmentedNode.selectedIndex))
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

    if indexPath.section == Section.header.rawValue {
      self.fillHeaderNode()
    } else if indexPath.section == Section.relatedData.rawValue {
      let category = self.category(withIndex: segmentedNode.selectedIndex)
      switch category {
      case .latest:
        //data is filled when node is created
        break
      case .editions:
        guard let cell = node as? BookNode else {
          return
        }

        let book = viewModel.edition(at: indexPath.item)
        cell.title = book?.title
        cell.author = book?.productDetails?.author
        cell.format = book?.productDetails?.productFormat
        cell.price = book?.supplierInformation?.preferredPrice?.formattedValue
        cell.imageUrl = book?.thumbnailImageUrl
      case .relatedBooks:
        guard let cell = node as? BookNode else {
          return
        }

        let book = viewModel.relatedBook(at: indexPath.item)
        cell.title = book?.title
        cell.author = book?.productDetails?.author
        cell.format = book?.productDetails?.productFormat
        cell.price = book?.supplierInformation?.preferredPrice?.formattedValue
        cell.imageUrl = book?.thumbnailImageUrl
      case .followers:
        guard let cell = node as? PenNameFollowNode else {
          return
        }

        let follower = viewModel.follower(at: indexPath.item)
        cell.penName = follower?.name
        cell.biography = follower?.biography
        cell.imageUrl = follower?.avatarUrl
        cell.following = follower?.following ?? false
      case .none:
        break
      }
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  private func cellNodeBlockFor(item: Int, category: Category) -> ASCellNode {
    switch category {
    case .latest:
      guard let post = viewModel.latest(at: item), let node = CardFactory.shared.createCardFor(resource: post) else {
        return ASCellNode()
      }
      return node
    case .editions:
      return BookNode()
    case .relatedBooks:
      return BookNode()
    case .followers:
      let penNameNode = PenNameFollowNode()
      penNameNode.showBottomSeparator = true
      penNameNode.delegate = self
      return penNameNode
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
      if let resource = viewModel.relatedBook(at: indexPath.item) {
        let vc = BookDetailsViewController(with: resource)
        navigationController?.pushViewController(vc, animated: true)
      }
    case .editions:
      if let resource = viewModel.edition(at: indexPath.item) {
        let vc = BookDetailsViewController(with: resource)
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

    let category = self.category(withIndex: segmentedNode.selectedIndex)

    guard context.isFetching() else {
      return
    }

    context.beginBatchFetching()
    self.setLoading(status: .loadMore)

    var callBackCategory: TopicViewModel.CallbackCategory = .content
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

      defer {
        context.completeBatchFetching(true)
        self.setLoading(status: .none)
      }

      if success {
        switch callBackCategory {
        case .latest, .editions, .relatedBooks, .followers:
          insert = true
        default:
          insert = false
        }

        if insert {
          let indexes: [IndexPath] = indices?.map({ IndexPath(item: $0, section: 1) }) ?? []
          collectionNode.insertItems(at: indexes)
        }
      }
    }
  }
}

// MARK: - Actions For Cards
extension TopicViewController {
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

  func pushPostDetailsViewController(resource: ModelResource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  func pushGenericViewControllerCard(resource: ModelResource, title: String? = nil) {
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
    let event: Analytics.Event = Analytics.Event(category: .Author,
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
