//
//  PostsListViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Spine

class PostsListViewController: ASViewController<ASCollectionNode> {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }
  fileprivate let collectionNodeLoadingSection: Int = 1
  fileprivate let collectionNodeItemsSection: Int = 0
  fileprivate let collectionNode: ASCollectionNode
  fileprivate let flowLayout: UICollectionViewFlowLayout
  fileprivate let loaderNode: LoaderNode

  fileprivate var loadingStatus: LoadingStatus = .none

  var viewModel: PostsListViewModel

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(title: String? = nil, ids: [String], preloadedList: [Resource]) {
    viewModel = PostsListViewModel(ids: ids, preloadedList: preloadedList)
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    super.init(node: collectionNode)

    collectionNode.style.flexGrow = 1
    collectionNode.style.flexShrink = 1
    collectionNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    self.title = title
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionNode.delegate = self
    collectionNode.dataSource = self

    loadingStatus = .loading
    viewModel.loadContentPosts { (success) in
      //Done Loading - Update UI
      self.loadingStatus = .none
      self.collectionNode.reloadData()
    }

    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }
}

extension PostsListViewController: ASCollectionDataSource, ASCollectionDelegate {

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      let shouldShow = !(loadingStatus == .none)
      loaderNode.updateLoaderVisibility(show: shouldShow)
      loaderNode.style.height = ASDimensionMake(shouldShow ? LoaderNode.defaultNodeHeight : 0.0)
      loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
      loaderNode.setNeedsLayout()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let section = indexPath.section

    return {
      if section == self.collectionNodeItemsSection {
        let cellNode = self.nodeForItem(nodeForItemAt: index)
        if let postCellNode = cellNode as? PostDetailItemNode {
          postCellNode.delegate = self
          return postCellNode
        }
        return cellNode
      } else {
        return self.loaderNode
      }
    }
  }

  func nodeForItem(nodeForItemAt index: Int) -> ASCellNode {
    guard let resource = viewModel.contentPostsItem(at: index) else {
      return ASCellNode()
    }
    //TODO: Refactor create posts facotry
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
      return ASCellNode()
    }
  }

  public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 2
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    if section == collectionNodeItemsSection {
      return viewModel.contentPostsItemCount()
    } else {
      return 1
    }
  }
}

extension PostsListViewController: PostDetailItemNodeDelegate {
  func postDetailItemNodeButtonTouchUpInside(postDetailItemNode: PostDetailItemNode, button: ASButtonNode) {
    guard let indexPath = collectionNode.indexPath(for: postDetailItemNode) else {
      return
    }
    guard let url = viewModel.contentPostsItem(at: indexPath.row)?.canonicalURL else {
      return
    }
    WebViewController.present(url: url, inViewController: self)
  }
}

// MARK: - Load More Logic
extension PostsListViewController {
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

    let initialLastIndexPath: Int = viewModel.contentPostsItemCount()

    viewModel.loadContentPosts { [weak self] (success) in
      defer {
        context.completeBatchFetching(true)
        self?.loadingStatus = .none
      }
      guard let strongSelf = self else {
        return
      }
      let finalLastIndexPath: Int = strongSelf.viewModel.contentPostsItemCount()

      if success && finalLastIndexPath > initialLastIndexPath {
        let updateIndexRange = initialLastIndexPath..<finalLastIndexPath

        let updatedIndexPathRange: [IndexPath]  = updateIndexRange.flatMap({ (index) -> IndexPath in
          return IndexPath(row: index, section: strongSelf.collectionNodeLoadingSection)
        })
        collectionNode.insertItems(at: updatedIndexPathRange)
      }
    }
  }
}

//MARK: - Localizable implementation
extension PostsListViewController: Localizable {
  func applyLocalization() {
    collectionNode.reloadData()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
