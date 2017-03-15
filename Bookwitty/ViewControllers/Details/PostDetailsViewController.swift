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
    postDetailsNode.delegate = self
    postDetailsNode.setWitValue(witted: viewModel.isWitted, wits: viewModel.wits ?? 0)
    postDetailsNode.setDimValue(dimmed: viewModel.isDimmed, dims: viewModel.dims ?? 0)
    postDetailsNode.booksHorizontalCollectionNode.dataSource = self
    postDetailsNode.booksHorizontalCollectionNode.delegate = self
    loadContentPosts()
    loadRelatedBooks()
    loadRelatedPosts()
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
  func shouldShowPostDetailsAllPosts() {
    if let contentPostIdentifiers = viewModel.contentPostsIdentifiers {
      if let contentPostsResources = viewModel.contentPostsResources {
        let vc = PostsListViewController(title: viewModel.title ?? title, ids: contentPostIdentifiers.flatMap({ $0.id }), preloadedList: contentPostsResources)
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }

  func shouldShowPostDetailsAllRelatedBooks() {
    //TODO: Push view controller
  }

  func shouldShowPostDetailsAllRelatedPosts() {
    //TODO: Push view controller
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
      //TODO: add cards action
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
      //TODO: handle Action
      break
    case Topic.resourceType:
      //TODO: handle Action
      break
    case Text.resourceType:
      //TODO: handle Action
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
    default:
      //TODO: handle comment
      break
    }
  }
}
// MARK - Actions
extension PostDetailsViewController {
  fileprivate func pushBookDetailsViewController(with book: Book) {
    let bookDetailsViewController = BookDetailsViewController(with: book)
    navigationController?.pushViewController(bookDetailsViewController, animated: true)
  }

}
