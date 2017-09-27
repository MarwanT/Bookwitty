//
//  TagFeedViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SwiftLoader

class TagFeedViewController: ASViewController<ASCollectionNode> {

  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let loaderNode: LoaderNode
  let refreshControllerer = UIRefreshControl()

  let viewModel = TagFeedViewModel()

  fileprivate var loadingStatus: LoadingStatus = .none
  fileprivate var shouldShowLoader: Bool {
    return (loadingStatus != .none && loadingStatus != .reloading)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    collectionNode.dataSource = self
    collectionNode.delegate = self

    title = viewModel.tag?.title

    collectionNode.view.addSubview(refreshControllerer)
    collectionNode.view.alwaysBounceVertical = true
    refreshControllerer.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)

    self.loadingStatus = .loading
    loadTagDetails()
    loadFeeds()
  }

  fileprivate func loadTagDetails() {
    viewModel.loadTagDetails { (success: Bool) in
      self.setupNavigationBarButtons()
    }
  }

  fileprivate func loadFeeds() {
    viewModel.loadFeeds { (success: Bool) in
      self.collectionNode.reloadData()

      self.loadingStatus = .none
      if self.refreshControllerer.isRefreshing {
        self.refreshControllerer.endRefreshing()
      }
    }
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    let following = viewModel.tag?.following ?? false
    let title =  following ? Strings.following() : Strings.follow()
    let button = UIButton(type: .custom)

    let attributedTitle = AttributedStringBuilder(fontDynamicType: .subheadline)
      .append(text: title, color: ThemeManager.shared.currentTheme.defaultButtonColor())
      .attributedString

    button.setAttributedTitle(attributedTitle, for: .normal)
    button.addTarget(self, action: #selector(self.rightBarButtonTouchUpInside(_:)), for: .touchUpInside)
    button.sizeToFit()
    let rightBarButtonItem = UIBarButtonItem(customView: button)
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }

  func pullToRefresh() {
    guard refreshControllerer.isRefreshing else {
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }
    guard loadingStatus == .none else {
      refreshControllerer.endRefreshing()
      //Making sure that only UIRefreshControl will trigger this on valueChanged
      return
    }

    self.loadingStatus = .reloading
    self.refreshControllerer.beginRefreshing()
    loadFeeds()
  }

  fileprivate func toggleTagFollowStatus() {
    let following = viewModel.tag?.following ?? false

    if following {
      viewModel.unfollowTag(completionBlock: { (success: Bool) in
        if success {
          self.loadTagDetails()
        }
      })
    } else {
      viewModel.followTag(completionBlock: { (success: Bool) in
        if success {
          self.loadTagDetails()
        }
      })
    }

    //MARK: [Analytics] Event
    let name: String = viewModel.tag?.title ?? ""
    let action: Analytics.Action = following ? .Unfollow : .Follow
    let event: Analytics.Event = Analytics.Event(category: .Tag,
                                                 action: action,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

// MARK: - Navigation Actions
extension TagFeedViewController {
  @objc
  fileprivate func rightBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    toggleTagFollowStatus()
  }
}

// MARK: - Declarations
extension TagFeedViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case cards
    case activityIndicator

    static var numberOfSections: Int {
      return 2
    }
  }
}

//MARK: ASCollectionDataSource, ASCollectionDelegate implementation
extension TagFeedViewController: ASCollectionDataSource, ASCollectionDelegate {
  private func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = self.viewModel.resourceForIndex(index: index) else {
      return nil
    }

    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }


  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Section.numberOfSections
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case TagFeedViewController.Section.cards.rawValue:
      return self.viewModel.data.count
    case TagFeedViewController.Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let section = indexPath.section
    return {
      if section == Section.cards.rawValue {
        let baseCardNode = self.nodeForItem(atIndex: index) ?? BaseCardPostNode()

        if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
          !readingListCell.node.isImageCollectionLoaded {
          let max = readingListCell.node.maxNumberOfImages
          self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
            if let imageCollection = imageCollection, imageCollection.count > 0 {
              readingListCell.node.prepareImages(imageCount: imageCollection.count)
              readingListCell.node.loadImages(with: imageCollection)
            }
          })
        }
        baseCardNode.delegate = self
        return baseCardNode
      } else if section == Section.activityIndicator.rawValue {
        return self.loaderNode
      } else {
        return ASCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: shouldShowLoader)
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(index: indexPath.row), let commonResource =  resource as? ModelCommonProperties else {
          return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
    }
  }

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

    viewModel.loadNext { (success: Bool) in
      collectionNode.performBatchUpdates({ 
        collectionNode.reloadSections(IndexSet(integer: Section.cards.rawValue))
        collectionNode.reloadSections(IndexSet(integer: Section.activityIndicator.rawValue))
      }, completion: { (finished: Bool) in
        self.loadingStatus = .none
      })
    }
  }
}

// MARK: - Actions For Cards
extension TagFeedViewController {
  func actionForCard(resource: ModelResource?) {
    guard let resource = resource,
      !DataManager.shared.isReported(resource) else {
      return
    }
    let registeredType = resource.registeredResourceType

    switch registeredType {
    case Image.resourceType:
      actionForImageResourceType(resource: resource)
    case ReadingList.resourceType:
      actionForReadingListResourceType(resource: resource)
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

  func pushPostDetailsViewController(resource: ModelResource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    nodeVc.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  func pushGenericViewControllerCard(resource: ModelResource, title: String? = nil) {
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

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? ReadingList)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .ReadingList,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
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
}

// MARK - BaseCardPostNode Delegate
extension TagFeedViewController: BaseCardPostNodeDelegate {

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
      let resource = viewModel.resourceForIndex(index: indexPath.item),
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

// MARK: - Compose comment delegate implementation
extension TagFeedViewController: CommentComposerViewControllerDelegate {
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
