//
//  ProfileDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

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

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }

  private func initializeComponents() {

    collectionNode.dataSource = self
    collectionNode.delegate = self
    
    initializeHeader()

    segmentedNode.initialize(with: segments.map({ $0.name }))
    segmentedNode.selectedSegmentChanged = segmentedNode(segmentedControlNode:didSelectSegmentIndex:)
    segmentedNode.style.preferredSize = CGSize(width: collectionNode.style.maxWidth.value, height: 45.0)
  }

  private func initializeHeader() {
    penNameHeaderNode.showBottomSeparator = false
    penNameHeaderNode.biography = viewModel.penName.biography
    penNameHeaderNode.penName = viewModel.penName.name
    penNameHeaderNode.following = viewModel.penName.following
    penNameHeaderNode.imageUrl = viewModel.penName.avatarUrl
    penNameHeaderNode.delegate = self
    penNameHeaderNode.updateMode(disabled: viewModel.isMyPenName())
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {
    self.activeSegment = segment(withIndex: index)
    self.loadData()
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
    self.collectionNode.reloadSections(IndexSet(integer: Section.cells.rawValue))
    self.collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
  }
}


extension ProfileDetailsViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ASButtonNode) {
    var penName: PenName?
    if penNameHeaderNode === node {
      penName = viewModel.penName
    } else if let indexPath = collectionNode.indexPath(for: node),
      let resource = viewModel.resourceForIndex(indexPath: indexPath, segment: activeSegment) {
      penName = resource as? PenName
    }

    if let penName = penName {
      if button.isSelected {
        viewModel.unfollowPenName(penName: penName, completionBlock: {
          (success: Bool) in
          node.following = false
          button.isSelected = false
        })
      } else {
        viewModel.followPenName(penName: penName, completionBlock: {
          (success: Bool) in
          node.following = true
          button.isSelected = true
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
}

extension ProfileDetailsViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
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

    let initialLastIndexPath: Int = viewModel.numberOfItemsInSection(section: Section.cells.rawValue, segment: activeSegment)

    // Fetch next page data
    viewModel.loadNextPage(for: activeSegment) { [weak self] (success) in
      defer {
        context.completeBatchFetching(true)
        self!.loadingStatus = .none
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.numberOfItemsInSection(section: Section.cells.rawValue, segment: strongSelf.activeSegment)

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        let updatedIndexPathRange: [IndexPath]  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: Section.cells.rawValue)
        })
        collectionNode.insertItems(at: updatedIndexPathRange)
      }
    }
  }
}

extension ProfileDetailsViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSection(section: section, segment: activeSegment)
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
        let showLoader = (loadingStatus != .none)
        loaderNode.updateLoaderVisibility(show: showLoader)
      }
    } else if indexPath.section == Section.cells.rawValue {
      switch activeSegment {
      case .followers:
        guard let cell = node as? PenNameFollowNode else {
          return
        }
        let follower: PenName? = viewModel.itemForSegment(segment: activeSegment, index: indexPath.row) as? PenName
        var isMyPenName: Bool = false
        if let follower = follower {
          isMyPenName = viewModel.isMyPenName(follower)
          cell.updateMode(disabled: isMyPenName)
        }
        cell.penName = follower?.name
        cell.biography = follower?.biography
        cell.imageUrl = follower?.avatarUrl
        cell.following = follower?.following ?? false
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
      let baseCardNode = CardFactory.shared.createCardFor(resource: resource)
      if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(segment: self.activeSegment, atIndexPath: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
      }
      baseCardNode?.delegate = self
      return baseCardNode
    case .followers:
      let penNameNode = PenNameFollowNode()
      penNameNode.showBottomSeparator = true
      penNameNode.delegate = self
      return penNameNode
    default: return nil
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension ProfileDetailsViewController: BaseCardPostNodeDelegate {
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }
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
    default:
      //TODO: handle comment
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

    let analyticsAction = Analytics.Action.actionFrom(cardAction: action)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

// MARK: - Actions For Cards
extension ProfileDetailsViewController {

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
