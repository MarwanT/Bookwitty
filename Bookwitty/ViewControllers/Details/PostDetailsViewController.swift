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
    self.title = title ?? viewModel.vcTitle
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
    postDetailsNode.delegate = self
    postDetailsNode.setWitValue(witted: viewModel.isWitted, wits: viewModel.wits ?? 0)
    postDetailsNode.setDimValue(dimmed: viewModel.isDimmed, dims: viewModel.dims ?? 0)
    postDetailsNode.booksHorizontalCollectionNode.dataSource = self
    postDetailsNode.booksHorizontalCollectionNode.delegate = self
    loadContentPosts()
    loadRelatedBooks()
    loadRelatedPosts()

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
      cell.price = book?.supplierInformation?.preferredPrice?.formattedValue
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
      WebViewController.present(url: url, inViewController: self)
  }

  func shouldShowPostDetailsAllPosts() {
    if let contentPostIdentifiers = viewModel.contentPostsIdentifiers {
      if let contentPostsResources = viewModel.contentPostsResources {
        let vc = PostsListViewController(title: viewModel.title ?? title, ids: contentPostIdentifiers.flatMap({ $0.id }), preloadedList: contentPostsResources)
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }

  func shouldShowPostDetailsAllRelatedBooks() {
    pushPostsViewController(resources: viewModel.relatedBooks, url: viewModel.relatedBooksNextPage)
  }

  func shouldShowPostDetailsAllRelatedPosts() {
    pushPostsViewController(resources: viewModel.relatedPosts, url: viewModel.relatedPostsNextPage)
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
      let itemNode = PostDetailItemNode(smallImage: false, showsSubheadline: false, showsButton: true)
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
    WebViewController.present(url: url, inViewController: self)
  }
}

// MARK - BaseCardPostNode Delegate
extension PostDetailsViewController: BaseCardPostNodeDelegate {
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
  }
}
// Mark: - Pen Name Header
extension PostDetailsViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ASButtonNode) {
    if button.isSelected {
      viewModel.unfollowPostPenName(completionBlock: {
        (success: Bool) in
        node.following = false
        button.isSelected = false
      })
    } else {
      viewModel.followPostPenName(completionBlock: {
        (success: Bool) in
        node.following = true
        button.isSelected = true
      })
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
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }

  fileprivate func actionForImageResourceType(resource: ModelResource) {
    pushGenericViewControllerCard(resource: resource)
  }

  fileprivate func actionForAuthorResourceType(resource: ModelResource) {
    pushTopicViewController(resource: resource)
  }

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    pushPostDetailsViewController(resource: resource)
  }

  fileprivate func actionForTopicResourceType(resource: ModelResource) {
    pushTopicViewController(resource: resource)
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
    pushTopicViewController(resource: resource)
  }
}

