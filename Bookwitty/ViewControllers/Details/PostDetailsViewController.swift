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
import AMScrollingNavbar

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

    postDetailsNode.title = viewModel.title
    postDetailsNode.coverImage = viewModel.image
    postDetailsNode.body = viewModel.body
    let date = Date.formatDate(date: viewModel.date)
    postDetailsNode.date = date
    postDetailsNode.penName = viewModel.penName
    postDetailsNode.conculsion = viewModel.conculsion
    postDetailsNode.postItemsNode.dataSource = self
    postDetailsNode.postCardsNode.dataSource = self
    postDetailsNode.postItemsNode.delegate = self
    postDetailsNode.postCardsNode.delegate = self
    postDetailsNode.headerNode.profileBarNode.delegate = self
    postDetailsNode.headerNode.profileBarNode.updateMode(disabled: viewModel.isMyPenName())
    postDetailsNode.delegate = self
    postDetailsNode.setWitValue(witted: viewModel.isWitted, wits: viewModel.wits ?? 0)
    postDetailsNode.setDimValue(dimmed: viewModel.isDimmed, dims: viewModel.dims ?? 0)
    postDetailsNode.booksHorizontalCollectionNode.dataSource = self
    postDetailsNode.booksHorizontalCollectionNode.delegate = self
    viewModel.loadPenName { (success) in
      self.postDetailsNode.penName = self.viewModel.penName
    }
    loadContentPosts()
    loadRelatedBooks()
    loadRelatedPosts()
    applyLocalization()
    observeLanguageChanges()

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let navigationController = navigationController as? ScrollingNavigationController {
      navigationController.followScrollView(postDetailsNode.view, delay: 50.0)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let navigationController = navigationController as? ScrollingNavigationController {
      navigationController.stopFollowingScrollView()
      navigationController.showNavbar(animated: true)
    }
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
      cell.price = (book?.productDetails?.isElectronicFormat() ?? false) ? nil : book?.supplierInformation?.preferredPrice?.formattedValue
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
    pushPostsViewController(resources: viewModel.relatedPosts, url: viewModel.relatedPostsNextPage)

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
    case .dim:
      viewModel.dimContent(completionBlock: { (success) in
        didFinishAction?(success)
      })
    case .undim:
      viewModel.undimContent(completionBlock: { (success) in
        didFinishAction?(success)
      })
    case .share:
      if let sharingInfo: [String] = viewModel.sharingPost() {
        presentShareSheet(shareContent: sharingInfo)
      }
    default:
      //TODO: handle comment
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
}

extension PostDetailsViewController: PostDetailsItemNodeDelegate {

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
      let card = CardFactory.shared.createCardFor(resource: resource)
      if let readingListCell = card as? ReadingListCardPostCellNode,
        !readingListCell.node.isImageCollectionLoaded {
        let max = readingListCell.node.maxNumberOfImages
        self.viewModel.loadReadingListImages(atIndex: index, maxNumberOfImages: max, completionBlock: { (imageCollection) in
          if let imageCollection = imageCollection, imageCollection.count > 0 {
            readingListCell.node.loadImages(with: imageCollection)
          }
        })
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
        !(res?.productDetails?.isElectronicFormat() ?? false)

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
      let date = Date.formatDate(date: res?.createdAt)
      itemNode.caption = date
      itemNode.headLine = res?.title
      itemNode.subheadLine = String(counting: res?.counts?.contributors)
      return itemNode
    case Text.resourceType:
      let res = resource as? Text
      let itemNode = PostDetailItemNode(smallImage: true, showsSubheadline: true, showsButton: false)
      itemNode.imageUrl = res?.thumbnailImageUrl
      itemNode.body = res?.shortDescription
      let date = Date.formatDate(date: res?.createdAt)
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
    guard let url = viewModel.canonicalURL else {
      return
    }
    WebViewController.present(url: url)


    //MARK: [Analytics] Event
    let resource = viewModel.resource
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
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let index = postDetailsNode.postCardsNode.index(of: card) else {
      return
    }
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

    default:
      //TODO: handle comment
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
}
// Mark: - Pen Name Header
extension PostDetailsViewController: PenNameFollowNodeDelegate {
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
    let bookDetailsViewController = BookDetailsViewController(with: book)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }

  fileprivate func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  fileprivate func pushGenericViewControllerCard(resource: Resource, title: String? = nil) {
    guard let cardNode = CardFactory.shared.createCardFor(resource: resource) else {
      return
    }
    let genericVC = CardDetailsViewController(node: cardNode, title: title, resource: resource)
    navigationController?.pushViewController(genericVC, animated: true)
  }

  fileprivate func pushTopicViewController(resource: Resource) {
    let topicViewController = TopicViewController()

    switch resource.registeredResourceType {
    case Author.resourceType:
      topicViewController.initialize(withAuthor: resource as? Author)
    case Book.resourceType:
      topicViewController.initialize(withBook: resource as? Book)
    case Topic.resourceType:
      topicViewController.initialize(withTopic: resource as? Topic)
    default: break
    }

    navigationController?.pushViewController(topicViewController, animated: true)
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
