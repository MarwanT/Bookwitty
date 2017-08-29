//
//  PostDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Spine
import Moya
import GSImageViewerController
import SwiftLoader

class PostDetailsViewController: ASViewController<PostDetailsNode> {
  let postDetailsNode: PostDetailsNode
  var viewModel: PostDetailsViewModel

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(title: String? = nil, resource: Resource) {
    viewModel = PostDetailsViewModel(resource: resource)
    postDetailsNode = PostDetailsNode()
    super.init(node: postDetailsNode)    
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initialize()
    addDelegatesAndDataSources()
    viewModel.loadPenName { (success) in
      self.postDetailsNode.penName = self.viewModel.penName
    }
    loadTags()
    loadContentPosts()
    loadComments()
    loadRelatedBooks()
    loadRelatedPosts()
    applyLocalization()
    observeLanguageChanges()
    //Observe Data Changes in the Data Center
    observeDataChanges()

    loadNavigationBarButtons()

    //MARK: [Analytics] Screen Name
    let name: Analytics.ScreenName
    switch(viewModel.resource.registeredResourceType) {
    case ReadingList.resourceType:
      name = Analytics.ScreenNames.ReadingList
    case Text.resourceType:
      name = Analytics.ScreenNames.Article
    default:
      name = Analytics.ScreenNames.Default
    }
    Analytics.shared.send(screenName: name)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    postDetailsNode.postCardsNode.updateNodes()
  }

  fileprivate func initialize() {
    postDetailsNode.title = viewModel.title
    postDetailsNode.coverImage = viewModel.image
    postDetailsNode.body = viewModel.body

    let date = viewModel.date?.formatted() ?? ""
    postDetailsNode.date = date
    postDetailsNode.penName = viewModel.penName
    postDetailsNode.actionInfoValue = viewModel.actionInfoValue
    postDetailsNode.conculsion = viewModel.conculsion
    postDetailsNode.headerNode.profileBarNode.updateMode(disabled: viewModel.isMyPenName())
    postDetailsNode.setWitValue(witted: viewModel.isWitted)

    postDetailsNode.tags = viewModel.tags
  }

  fileprivate func addDelegatesAndDataSources() {
    postDetailsNode.postItemsNode.dataSource = self
    postDetailsNode.postCardsNode.dataSource = self
    postDetailsNode.postItemsNode.delegate = self
    postDetailsNode.postCardsNode.delegate = self
    postDetailsNode.headerNode.profileBarNode.delegate = self
    postDetailsNode.delegate = self
    postDetailsNode.booksHorizontalCollectionNode.dataSource = self
    postDetailsNode.booksHorizontalCollectionNode.delegate = self
  }

  private func loadNavigationBarButtons() {
    //Set the back button item to remove the back-title
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    //Set the sharing icon and action in the navigation bar
    let shareButton = UIBarButtonItem(
      image: #imageLiteral(resourceName: "shareOutside"),
      style: UIBarButtonItemStyle.plain,
      target: self,
      action: #selector(shareOutsideButton(_:)))
    navigationItem.rightBarButtonItem = shareButton
  }

  func shareOutsideButton(_ sender: Any?) {
    if let sharingInfo: [String] = viewModel.sharingPost() {
      presentShareSheet(shareContent: sharingInfo)
    }
  }

  func loadTags() {
    guard viewModel.tags?.count ?? 0 == 0 else {
      return
    }

    viewModel.loadTags { (success: Bool, error: BookwittyAPIError?) in
      self.postDetailsNode.tags = self.viewModel.tags
    }
  }

  func loadContentPosts() {
    guard viewModel.shouldLoadContentPosts() else {
      return
    }
    //Start Loading
    postDetailsNode.showPostsLoader = true
    viewModel.loadContentPosts { (success) in
      //Done Loading - Update UI
      self.postDetailsNode.showPostsLoader = false
      self.postDetailsNode.loadPostItemsNode()
    }
  }
  
  func loadComments() {
    guard let id = viewModel.resource.id else {
      return
    }
    postDetailsNode.loadComments(with: id)
  }

  func loadRelatedBooks() {
    postDetailsNode.showRelatedBooksLoader = true
    viewModel.getRelatedBooks { (success) in
      self.postDetailsNode.showRelatedBooksLoader = false
      if success {
        self.postDetailsNode.booksHorizontalCollectionNode.reloadData()
      }
    }
  }

  func loadRelatedPosts() {
    postDetailsNode.showRelatedPostsLoader = true
    self.viewModel.getRelatedPosts(completionBlock: { (success) in
      self.postDetailsNode.showRelatedPostsLoader = false
      if success {
        self.postDetailsNode.loadRelatedCards()
      }
    })
  }
}

extension PostDetailsViewController: ASCollectionDataSource, ASCollectionDelegate {
  public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfRelatedBooks()
  }
  public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 1
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> AsyncDisplayKit.ASCellNodeBlock {
    let book = viewModel.relatedBook(at: indexPath.row)
    return {
      let cell = RelatedBooksMinimalCellNode()
      cell.url = book?.thumbnailImageUrl
      cell.price = (book?.productDetails?.isElectronicFormat ?? false) ? nil : book?.supplierInformation?.preferredPrice?.formattedValue
      cell.subTitle = book?.productDetails?.author
      cell.title = book?.title
      return cell
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard let book = viewModel.relatedBook(at: indexPath.row) else {
      return
    }
    pushBookDetailsViewController(with: book)
  }
}

extension PostDetailsViewController: PostDetailsNodeDelegate {
  func bannerTapAction(url: URL?) {
      WebViewController.present(url: url)
  }

  func shouldShowPostDetailsAllPosts() {
    if viewModel.contentPostsIdentifiers?.count ?? 0 > 0 {
      if let contentPostsResources = viewModel.contentPostsResources {
        let vc = PostsListViewController(title: viewModel.title ?? title, nextPage: viewModel.contentPostsNextPage, preloadedList: contentPostsResources)
        self.navigationController?.pushViewController(vc, animated: true)

        //MARK: [Analytics] Event
        let resource = viewModel.resource
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

        let event: Analytics.Event = Analytics.Event(category: category,
                                                     action:.ViewAllReadingListContent,
                                                     name: name)
        Analytics.shared.send(event: event)
      }
    }
  }

  func shouldShowPostDetailsAllRelatedBooks() {
    pushPostsViewController(resources: viewModel.relatedBooks, url: viewModel.relatedBooksNextPage)

    //MARK: [Analytics] Event
    let resource = viewModel.resource
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

    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action:.ViewAllRelatedBooks,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func shouldShowPostDetailsAllRelatedPosts() {
    pushPostsViewController(resources: viewModel.relatedPostsResources(), url: viewModel.relatedPostsNextPage)

    //MARK: [Analytics] Event
    let resource = viewModel.resource
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

    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action:.ViewAllRelatedPosts,
                                                 name: name)
    Analytics.shared.send(event: event)
  }

  func hasRelatedPosts() -> Bool {
    return viewModel.numberOfRelatedPosts() > 0
  }

  func hasRelatedBooks() -> Bool {
    return viewModel.numberOfRelatedBooks() > 0
  }

  func hasContentItems() -> Bool {
    return viewModel.contentPostsItemCount() > 0
  }

  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    switch(action) {
    case .wit:
      viewModel.witPost(completionBlock: { (success) in
          didFinishAction?(success)
      })
    case .unwit:
      viewModel.unwitPost(completionBlock: { (success) in
        didFinishAction?(success)
      })
    case .share:
      if let sharingInfo: [String] = viewModel.sharingPost() {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .comment:
      pushCommentsViewController(for: viewModel.resource as? ModelCommonProperties)
      didFinishAction?(true)
    default:
      break
    }

    //MARK: [Analytics] Event
    let resource = viewModel.resource
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

  func postDetails(node: PostDetailsNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
    let transitionInfo = GSTransitionInfo(fromView: imageNode.view)
    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
    present(imageViewer, animated: true, completion: nil)
  }

  func postDetails(node: PostDetailsNode, didRequestActionInfo fromNode: ASTextNode) {
    pushPenNamesListViewController(with: viewModel.resource)
  }
  
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action) {
    switch action {
    case .viewRepliesForComment(let comment, let postId):
      break
    case .viewAllComments(let commentsManager):
      pushCommentsViewController(with: commentsManager)
    case .writeComment(let parentCommentIdentifier, _):
      CommentComposerViewController.show(from: self, delegate: self, postId: nil, parentCommentId: parentCommentIdentifier)
    case .commentAction(let comment, let action):
      switch action {
      case .wit:
        postDetailsNode.wit(comment: comment, completion: nil)
      case .unwit:
        postDetailsNode.unwit(comment: comment, completion: nil)
      case .reply:
        CommentComposerViewController.show(from: self, delegate: self, postId: nil, parentCommentId: comment.id)
      default:
        break
      }
    }
  }

  func postDetails(node: PostDetailsNode, didSelectTagAt index: Int) {
    guard let tags = (self.viewModel.resource as? ModelCommonProperties)?.tags else {
      return
    }

    guard index >= 0 && index < tags.count else {
      return
    }

    let tag = tags[index]

    let tagController = TagFeedViewController()
    tagController.viewModel.tag = tag
    self.navigationController?.pushViewController(tagController, animated: true)
  }
}

extension PostDetailsViewController: PostDetailsItemNodeDelegate {
  func shouldUpdateItem(_ postDetailsItem: PostDetailsItemNode, at index: Int, displayNode: ASDisplayNode) {
    if let card = displayNode as? BaseCardPostNode {
      guard let resource = viewModel.relatedPostsResourceForIndex(index: index) as? ModelCommonProperties else {
        return
      }
      card.baseViewModel?.resource = resource
      card.setNeedsLayout()
      
      if let bookCard = card as? BookCardPostCellNode, let book = resource as? Book {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: book , section: BookTypeRegistry.Section.postDetails) ?? .topic == .product)
      }
    }
  }

  func postDetails(_ postDetailsItem: PostDetailsItemNode, node: ASDisplayNode, didSelectItemAt index: Int) {
    if postDetailsNode.postCardsNode === postDetailsItem {
      guard let resource = viewModel.relatedPost(at: index) else {
        return
      }
      actionForCard(resource: resource)
    } else {
      guard let resource = viewModel.contentPostsItem(at: index) else {
        return
      }
      handleContentPostsTap(resource: resource)
    }
  }

  func handleContentPostsTap(resource: ModelResource) {
    switch (resource.registeredResourceType) {
    case Book.resourceType:
      if let book = resource as? Book {
        pushBookDetailsViewController(with: book)
      }
      break
    case Topic.resourceType:
      actionForTopicResourceType(resource: resource)
      break
    case Text.resourceType:
      actionForTextResourceType(resource: resource)
      break
    default: break
    }
  }
}

extension PostDetailsViewController: PostDetailsItemNodeDataSource {

  func postDetailsItem(_ postDetailsItem: PostDetailsItemNode, nodeForItemAt index: Int) -> ASDisplayNode {
    if postDetailsNode.postCardsNode === postDetailsItem {
      guard let resource = viewModel.relatedPost(at: index) else {
        return BaseCardPostNode()
      }
      let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
      card?.baseViewModel?.resource = resource as? ModelCommonProperties
      if let readingListCell = card as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.prepareImages(imageCount: imageCollection.count)
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
      } else if let bookCard = card as? BookCardPostCellNode {
        bookCard.isProduct = (self.viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.postDetails) ?? .topic == .product)
      }

      card?.delegate = self
      return  card ?? BaseCardPostNode()
    } else {
      return cellItemForPostDetails(at: index)
    }
  }

  func postDetailsItemCount(_ postDetailsItem: PostDetailsItemNode) -> Int {
    if postDetailsNode.postCardsNode === postDetailsItem {
      return viewModel.numberOfRelatedPosts()
    } else {
      return viewModel.contentPostsItemCount()
    }
  }

  func cellItemForPostDetails(at index: Int) -> ASDisplayNode {
    guard let resource = viewModel.contentPostsItem(at: index) else {
      return ASDisplayNode()
    }
    switch (resource.registeredResourceType) {
    case Book.resourceType:
      let res = resource as? Book
      let showEcommerceButton: Bool = (res?.supplierInformation != nil) &&
        !(res?.productDetails?.isElectronicFormat ?? false)

      let itemNode = PostDetailItemNode(smallImage: false, showsSubheadline: false, showsButton: showEcommerceButton)
      itemNode.imageUrl = res?.thumbnailImageUrl
      itemNode.body = res?.bookDescription
      itemNode.buttonTitle = Strings.buy_this_book()
      itemNode.caption = res?.productDetails?.author
      itemNode.headLine = res?.title
      itemNode.subheadLine = nil
      itemNode.delegate = self
      return itemNode
    case Topic.resourceType:
      let res = resource as? Topic
      let itemNode = PostDetailItemNode(smallImage: true, showsSubheadline: true, showsButton: false)
      itemNode.imageUrl = res?.thumbnailImageUrl
      itemNode.body = res?.shortDescription
      let date = res?.createdAt?.formatted() ?? ""
      itemNode.caption = date
      itemNode.headLine = res?.title
      itemNode.subheadLine = String(counting: res?.counts?.contributors)
      return itemNode
    case Text.resourceType:
      let res = resource as? Text
      let itemNode = PostDetailItemNode(smallImage: true, showsSubheadline: true, showsButton: false)
      itemNode.imageUrl = res?.thumbnailImageUrl
      itemNode.body = res?.shortDescription
      let date = res?.createdAt?.formatted() ?? ""
      itemNode.caption = date
      itemNode.headLine = res?.title
      itemNode.subheadLine = res?.penName?.name
      return itemNode
    default :
      return ASDisplayNode()
    }
  }
}

extension PostDetailsViewController: PostDetailItemNodeDelegate {
  func postDetailItemNodeButtonTouchUpInside(postDetailItemNode: PostDetailItemNode, button: ASButtonNode) {
    guard let index = postDetailItemNode.tapDelegate?.indexFor(node: postDetailItemNode) else {
      return
    }

    guard let resource = viewModel.contentPostsItem(at: index),
      let url = resource.canonicalURL else {
        return
    }

    WebViewController.present(url: url)

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

    let name = postDetailItemNode.headLine ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: .BuyThisBook,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

// MARK - BaseCardPostNode Delegate
extension PostDetailsViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler(at index: Int) {
    let resource = viewModel.relatedPost(at: index)
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

  private func actionInfoHandler(at index: Int) {
    guard let resource = viewModel.relatedPost(at: index) else {
      return
    }

    pushPenNamesListViewController(with: resource)
  }

  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let index = postDetailsNode.postCardsNode.index(of: card) else {
      return
    }
    
    switch action {
    case .userProfile:
      userProfileHandler(at: index)
    case .actionInfo:
      actionInfoHandler(at: index)
    }
  }

  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    guard let index = postDetailsNode.postCardsNode.index(of: card) else {
      return
    }

    switch(action) {
    case .wit:
      viewModel.witRelatedPost(index: index) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitRelatedPost(index: index) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingRelatedPost(index: index) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.followRelatedPost(index: index) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollowRelatedPost(index: index) { (success) in
        didFinishAction?(success)
      }
    case .comment:
      guard let resource = viewModel.relatedPost(at: index) else { return }
      pushCommentsViewController(for: resource as? ModelCommonProperties)
      didFinishAction?(true)
    default:
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.relatedPost(at: index) else { return }
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
    //Empty Implementation
    /* Discussion
     * Top Comment Node Is Not Visible Here
     */
  }

  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int) {
    //Empty Implementation
  }
}

// Mark: - Pen Name Header
extension PostDetailsViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    penName(node: node, actionPenNameFollowTouchUpInside: imageNode)
  }

  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader) {
    button.state = .loading
    if button.isSelected {
      viewModel.unfollowPostPenName(completionBlock: {
        (success: Bool) in
        node.following = !success
        button.state = success ? .normal : .selected
      })
    } else {
      viewModel.followPostPenName(completionBlock: {
        (success: Bool) in
        node.following = success
        button.state = success ? .selected : .normal
      })
    }
  }

  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?) {
    if let penName = viewModel.penName {
      pushProfileViewController(penName: penName)

      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                   action: .GoToDetails,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    }
  }
}

// MARK - Actions
extension PostDetailsViewController {
  fileprivate func pushPostsViewController(resources: [ModelResource]?, url: URL?) {
    let postsViewController = PostsViewController()
    postsViewController.initialize(title: nil, resources: resources, loadingMode: PostsViewModel.DataLoadingMode.server(absoluteURL: url))
    navigationController?.pushViewController(postsViewController, animated: true)
  }

  fileprivate func pushBookDetailsViewController(with book: Book) {
    let bookDetailsViewController = BookDetailsViewController()
    bookDetailsViewController.initialize(with: book)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }

  fileprivate func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  fileprivate func pushGenericViewControllerCard(resource: Resource, title: String? = nil) {
    guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
      return
    }
    
    cardNode.baseViewModel?.resource = resource as? ModelCommonProperties
    let genericVC = CardDetailsViewController(node: cardNode, title: title, resource: resource)
    navigationController?.pushViewController(genericVC, animated: true)
  }

  fileprivate func pushTopicViewController(resource: Resource) {
    let topicViewController = TopicViewController()

    switch resource.registeredResourceType {
    case Book.resourceType:
      guard let resource = resource as? Book else {
        return
      }

      let isProduct = (viewModel.bookRegistry.category(for: resource , section: BookTypeRegistry.Section.postDetails) ?? .topic == .product)
      if !isProduct {
        topicViewController.initialize(with: resource as ModelCommonProperties)
        navigationController?.pushViewController(topicViewController, animated: true)
      } else {
        let bookDetailsViewController = BookDetailsViewController()
        bookDetailsViewController.initialize(with: resource)
        bookDetailsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookDetailsViewController, animated: true)
      }
    case Author.resourceType, Topic.resourceType:
      topicViewController.initialize(with: resource as? ModelCommonProperties)
      navigationController?.pushViewController(topicViewController, animated: true)
    default: break
    }
  }
  
  func pushCommentsViewController(with commentsManager: CommentsManager) {
    let commentsVC = CommentsViewController()
    commentsVC.initialize(with: commentsManager)
    self.navigationController?.pushViewController(commentsVC, animated: true)
  }
}

// MARK: - Actions For Cards
extension PostDetailsViewController {
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
    //MARK: [Analytics] Event
    let name: String = (resource as? Author)?.name ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Author,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushTopicViewController(resource: resource)
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
    //MARK: [Analytics] Event
    let name: String = (resource as? Topic)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .Topic,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushTopicViewController(resource: resource)
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
    //MARK: [Analytics] Event
    let name: String = (resource as? Book)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .TopicBook,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushTopicViewController(resource: resource)
  }
}

//MARK: - Observe Data Changes
extension PostDetailsViewController {
  fileprivate func observeDataChanges() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
  }

  @objc
  fileprivate func updatedResources(_ notification: NSNotification) {
    guard let resourceId = viewModel.resource.id,
      let identifiers = notification.object as? [String],
      identifiers.count > 0 else {
        return
    }
    
    if viewModel.updateAffectedPostDetails(resourcesIdentifiers: identifiers) {
      guard let resource = DataManager.shared.fetchResource(with: resourceId) else {
        return
      }
      viewModel.resource = resource
      initialize()
    }

    //Update the cards custom collection only.
    let visibleCardIndices: [Int] = postDetailsNode.postCardsNode.visibleNodes()
    let affectedCardItems = viewModel.relatedPostsAffectedItems(identifiers: identifiers, visibleItemsIndices: visibleCardIndices)
    if affectedCardItems.count > 0 {
      postDetailsNode.postCardsNode.updateNodes(with: affectedCardItems)
    }

    //Note: Do not update the books sections
    //TODO: Refactor this view controller => Use Only Collection and Sections
  }
}

//MARK: - Localizable implementation
extension PostDetailsViewController: Localizable {
  func applyLocalization() {
    postDetailsNode.postItemsNode.loadNodes()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

// MARK: - Compose comment delegate implementation
extension PostDetailsViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func commentComposerPublish(_ viewController: CommentComposerViewController, content: String?, postId: String?, parentCommentId: String?) {
    SwiftLoader.show(animated: true)
    postDetailsNode.publishComment(content: content, parentCommentId: parentCommentId) {
      (success, error) in
      SwiftLoader.hide()
      guard success else {
        if let error = error {
          self.showAlertWith(title: error.title ?? "", message: error.message ?? "", handler: {
            (_) in
            // Restart editing the comment
            _ = viewController.becomeFirstResponder()
          })
        }
        return
      }
      
      self.dismiss(animated: true, completion: nil)
    }
  }
}
