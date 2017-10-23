//
//  ProfileDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import GSImageViewerController
import SwiftLoader

class ProfileDetailsViewController: ASViewController<ASCollectionNode> {
  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let penNameHeaderNode: PenNameFollowNode
  fileprivate var segmentedNode: SegmentedControlNode

  fileprivate var viewModel: ProfileDetailsViewModel!
  fileprivate var segments: [Segment] = [.latest(index: 0), .followers(index: 1), .following(index: 2)]
  fileprivate var activeSegment: Segment
  fileprivate var loaderNode: LoaderNode
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

  class func create(with viewModel: ProfileDetailsViewModel) -> ProfileDetailsViewController {
    let profileVC = ProfileDetailsViewController()
    profileVC.viewModel = viewModel
    return profileVC
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    collectionNode.onDidLoad { (node) in
      (node.view as? ASCollectionView)?.leadingScreensForBatching = 6
    }
    segmentedNode = SegmentedControlNode()
    loaderNode = LoaderNode()
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    activeSegment = segments[0]
    penNameHeaderNode = PenNameFollowNode(enlarged: true)

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    applyTheme()
    loadData()
    applyLocalization()
    observeLanguageChanges()
    addDataObserver()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.UserProfile)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func initializeComponents() {

    collectionNode.dataSource = self
    collectionNode.delegate = self

    initializeHeader()
    reloadPenName()

    segmentedNode.initialize(with: segments.map({ $0.name }))
    segmentedNode.selectedSegmentChanged = { [weak self] (segmentedControlNode: SegmentedControlNode, index: Int) in
      self?.segmentedNode(segmentedControlNode: segmentedControlNode, didSelectSegmentIndex: index)
    }
    segmentedNode.style.preferredSize = CGSize(width: collectionNode.style.maxWidth.value, height: 45.0)
  }

  private func initializeHeader() {
    penNameHeaderNode.showBottomSeparator = false
    penNameHeaderNode.biography = viewModel.penName.biography
    penNameHeaderNode.penName = viewModel.penName.name
    penNameHeaderNode.following = viewModel.penName.following
    penNameHeaderNode.imageUrl = viewModel.penName.avatarUrl
    penNameHeaderNode.showMoreButton = !viewModel.isMyPenName()
    penNameHeaderNode.delegate = self
    penNameHeaderNode.updateMode(disabled: viewModel.isMyPenName())
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {
    self.activeSegment = segment(withIndex: index)
    self.loadData()

    //MARK: [Analytics] Event
    var analyticsAction: Analytics.Action = .Default
    switch activeSegment {
    case .latest:
      analyticsAction = .GoToLatest
    case .followers:
      analyticsAction = .GoToFollowers
    case .following:
      analyticsAction = .GoToFollowings
    default:
      break
    }
    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                 action: analyticsAction,
                                                 name: viewModel.penName.name ?? "")
    Analytics.shared.send(event: event)
  }

  func reloadPenName() {
    viewModel.loadPenName { (success) in
      self.initializeHeader()
    }
  }

  func loadData() {
    self.loadingStatus = .reloading
    self.reloadCollectionSections()
    viewModel.data(for: activeSegment) { (success, error) in
      self.loadingStatus = .none
      self.reloadCollectionSections()
    }
  }

  private func reloadCollectionSections() {
    updateCollection(with: nil, shouldReloadItems: false, loaderSection: true, cellsSection: true, orReloadAll: false, completionBlock: nil)
  }
}


extension ProfileDetailsViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    if penNameHeaderNode === node {
      let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
      let transitionInfo = GSTransitionInfo(fromView: imageNode.view)
      let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
      present(imageViewer, animated: true, completion: nil)
    } else {
      penName(node: node, actionPenNameFollowTouchUpInside: imageNode)
    }
  }

  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader) {
    var penName: PenName?
    if penNameHeaderNode === node {
      penName = viewModel.penName
    } else if let indexPath = collectionNode.indexPath(for: node),
      let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) {
      penName = resource as? PenName
    }
    button.state = .loading
    if let penName = penName {
      if button.isSelected {
        viewModel.unfollowPenName(penName: penName, completionBlock: {
          (success: Bool) in
          node.following = !success
          button.state = success ? .normal : .selected
        })
      } else {
        viewModel.followPenName(penName: penName, completionBlock: {
          (success: Bool) in
          node.following = success
          button.state = success ? .selected : .normal
        })
      }
    }
  }

  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?) {
    if penNameHeaderNode === node {
      //Note: Do not open the Pen Name profile view again we are already in it
      return
    } else if let indexPath = collectionNode.indexPath(for: node),
      let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) {
      if let penName = resource as? PenName {
        pushProfileViewController(penName: penName)

        //MARK: [Analytics] Event
        let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                     action: .GoToDetails,
                                                     name: penName.name ?? "")
        Analytics.shared.send(event: event)
      }
    }
  }

  func penName(node: PenNameFollowNode, moreButtonTouchUpInside button: ASButtonNode?) {
    
    let penNameIdentifier: String
    let penNameResource: PenName
    if penNameHeaderNode === node {
      guard let identifier = viewModel.penName.id else {
        return
      }
      penNameIdentifier = identifier
      penNameResource = viewModel.penName
    } else {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment),
        let penName = resource as? PenName,
        let identifier = penName.id else {
          return
      }
      penNameIdentifier = identifier
      penNameResource = penName
    }

    let actions: [MoreAction] = MoreAction.actions(for: penNameResource as? ModelCommonProperties)
    self.showMoreActionSheet(identifier: penNameIdentifier, actions: actions, completion: {
      (success: Bool) in

    })
  }
}

extension ProfileDetailsViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == Section.cells.rawValue else {
      return
    }

    let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment)
    actionForCard(resource: resource)
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage(segment: activeSegment)
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

    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cells.rawValue, segment: activeSegment)

    // Fetch next page data
    viewModel.loadNextPage(for: activeSegment) { [weak self] (success) in
      var updatedIndexPathRange: [IndexPath]?
      defer {
        context.completeBatchFetching(true)
        self?.loadingStatus = .none
        self?.updateCollection(with: updatedIndexPathRange, shouldReloadItems: false, loaderSection: true, cellsSection: false, orReloadAll: false, completionBlock: nil)
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection(section: Section.cells.rawValue, segment: strongSelf.activeSegment)

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        updatedIndexPathRange = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cells.rawValue)
        })
      }
    }
  }
}

extension ProfileDetailsViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    if section == Section.activityIndicator.rawValue {
      return shouldShowLoader ? 1 : 0
    } else {
      return viewModel.numberOfItemsInSection(section: section, segment: activeSegment)
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let indexPath = indexPath
    let section = indexPath.section
    return {
      guard section == Section.cells.rawValue else {
        switch section {
        case Section.segmentedControl.rawValue : return self.segmentedNode
        case Section.profileInfo.rawValue: return self.penNameHeaderNode
        case Section.activityIndicator.rawValue : return self.loaderNode
        default: return ASCellNode()
        }
      }
      return self.nodeForSegment(with: indexPath) ?? ASCellNode()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }
    if indexPath.section == Section.activityIndicator.rawValue {
      if let loaderNode = node as? LoaderNode {
        loaderNode.updateLoaderVisibility(show: shouldShowLoader)
      }
    } else if indexPath.section == Section.cells.rawValue {
      switch activeSegment {
      case .followers:
        guard let cell = node as? PenNameFollowNode else {
          return
        }
        let follower: PenName? = viewModel.itemForSegment(segment: activeSegment, index: indexPath.row) as? PenName
        setupPenNameData(in: cell, with: follower)
      case .following:
        fallthrough
      case .latest:
        if let card = node as? BaseCardPostNode {
          guard let indexPath = collectionNode.indexPath(for: node),
            let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment), let commonResource =  resource as? ModelCommonProperties else {
              return
          }


          if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
            card.baseViewModel?.resource = commonResource
          }
          if let registrySection = activeSegment.registrySection, let bookCard = card as? BookCardPostCellNode {
            bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: registrySection) ?? .topic == .product)
          }
        }
      default: break
      } 
    }
  }

  func nodeForSegment(with indexPath: IndexPath) -> ASCellNode? {
    return nodeForItem(atIndexPath: indexPath, segment: activeSegment)
  }

  func nodeForItem(atIndexPath indexPath: IndexPath, segment: ProfileDetailsViewController.Segment) -> ASCellNode? {
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: segment) else {
      return nil
    }
    switch segment {
    case .latest, .following:
      let baseCardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
      baseCardNode?.baseViewModel?.resource = resource as? ModelCommonProperties

      if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(segment: self.activeSegment, atIndexPath: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.prepareImages(imageCount: imageCollection.count)
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
      } else if let registrySection = segment.registrySection,  let bookCard = baseCardNode as? BookCardPostCellNode, let resource = resource as? Book {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: registrySection) ?? .topic == .product)
      }

      baseCardNode?.delegate = self
      return baseCardNode
    case .followers:
      let penNameNode = PenNameFollowNode()
      penNameNode.showBottomSeparator = true
      penNameNode.delegate = self
      let follower: PenName? = viewModel.itemForSegment(segment: activeSegment, index: indexPath.row) as? PenName
      setupPenNameData(in: penNameNode, with: follower)
      return penNameNode
    default: return nil
    }
  }


  func setupPenNameData(in penNameNode: PenNameFollowNode,with follower: PenName?) {
    var isMyPenName: Bool = false
    if let follower = follower {
      isMyPenName = viewModel.isMyPenName(follower)
      penNameNode.updateMode(disabled: isMyPenName)
    }
    penNameNode.penName = follower?.name
    penNameNode.biography = follower?.biography
    penNameNode.imageUrl = follower?.avatarUrl
    penNameNode.following = follower?.following ?? false
    if let follower = follower {
      penNameNode.showMoreButton = !UserManager.shared.isMy(penName: follower)
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension ProfileDetailsViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment)
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
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) else {
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
      viewModel.witContent(segment: activeSegment, indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(segment: activeSegment, indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(segment: activeSegment, indexPath: indexPath) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow(segment: activeSegment, indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(segment: activeSegment, indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .comment:
      guard let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) else { return }
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment),
        let identifier = resource.id else { return }

      let actions: [MoreAction] = MoreAction.actions(for: resource as? ModelCommonProperties)
      self.showMoreActionSheet(identifier: identifier, actions: actions, completion: { (success: Bool) in
        didFinishAction?(success)
      })
    default:
      break
    }

    //MARK: [Analytics] Event

    guard let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) else { return }
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
      let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) as? ModelCommonProperties else {
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
extension ProfileDetailsViewController {

  fileprivate func actionForCard(resource: ModelResource?) {
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
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    guard resource is Author else {
      return
    }

    let topicViewController = TopicViewController()
    topicViewController.initialize(with: resource as? ModelCommonProperties)
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
    topicViewController.initialize(with: resource as? ModelCommonProperties)
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
    guard let resource = resource as? Book else {
      return
    }

    var isProduct = false
    if let registrySection = activeSegment.registrySection {
      isProduct = (viewModel.bookRegistry.category(for: resource , section: registrySection) ?? .topic == .product)
    }
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

extension ProfileDetailsViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

// MARK: - Declarations
extension ProfileDetailsViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case profileInfo = 0
    case segmentedControl
    case cells
    case activityIndicator

    static var numberOfSections: Int {
      return 4
    }
  }

  enum Segment {
    case latest(index: Int)
    case followers(index: Int)
    case following(index: Int)
    case none


    var registrySection: BookTypeRegistry.Section? {
      switch self {
      case .latest:
        return BookTypeRegistry.Section.profileLatest
      case .followers:
        return BookTypeRegistry.Section.profileFollowing
      case .following:
        fallthrough
      case .none:
        return nil
      }
    }

    var name: String {
      switch self {
      case .latest:
        return Strings.latest()
      case .followers:
        return Strings.followers()
      case .following:
        return Strings.following()
      case .none:
        return ""
      }
    }

    var index: Int {
      switch self {
      case .latest(let index):
        return index
      case .followers(let index):
        return index
      case .following(let index):
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

//MARK: - Localizable implementation
extension ProfileDetailsViewController {
  fileprivate func addDataObserver() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
  }

  @objc
  private func updatedResources(_ notification: NSNotification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems.filter({ $0.section == Section.cells.rawValue })

    guard let identifiers = notification.object as? [String],
      identifiers.count > 0,
      visibleItemsIndexPaths.count > 0 else {
        return
    }

    let indexPathForAffectedItems = viewModel.indexPathForAffectedItems(resourcesIdentifiers: identifiers, visibleItemsIndexPaths: visibleItemsIndexPaths, segment: activeSegment)
    updateCollection(with: indexPathForAffectedItems, shouldReloadItems: true, loaderSection: true, cellsSection: false, orReloadAll: false, completionBlock: nil)
  }

}

//MARK: - Localizable implementation
extension ProfileDetailsViewController: Localizable {
  func applyLocalization() {
    segmentedNode.initialize(with: segments.map({ $0.name }))
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

// MARK: - Reload Footer
extension ProfileDetailsViewController {
  func updateCollection(with itemIndices: [IndexPath]? = nil, shouldReloadItems reloadItems: Bool = false, loaderSection: Bool = false, cellsSection: Bool = false, orReloadAll reloadAll: Bool = false, completionBlock: ((Bool) -> ())? = nil) {
    if reloadAll {
      collectionNode.reloadData(completion: {
        completionBlock?(true)
      })
    } else {
      collectionNode.performBatchUpdates({
        if loaderSection {
          collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
        }
        if cellsSection {
          collectionNode.reloadSections(IndexSet(integer: Section.cells.rawValue))
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
extension ProfileDetailsViewController: CommentComposerViewControllerDelegate {
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
