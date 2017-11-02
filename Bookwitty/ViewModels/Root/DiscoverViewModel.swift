//
//  DiscoverViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine
import AsyncDisplayKit

final class DiscoverViewModel {
  var bookRegistry: BookTypeRegistry = BookTypeRegistry()
  var cancellableRequest:  Cancellable?
  //All data identifier
  var contentIdentifiers: [String] = []
  var booksIdentifiers: [String] = []
  var pagesIdentifiers: [String] = []
  //Displayed data item
  var contentData: [String] = []
  var booksData: [String] = []
  var pagesData: [String] = []

  fileprivate var contentPaginator: Paginator?
  fileprivate var booksPaginator: Paginator?
  fileprivate var pagesPaginator: Paginator?

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func cancelOnGoingRequest() {
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }
  }

  func refreshData(for segment: DiscoverViewController.Segment, afterDataEmptied: (() -> ())? = nil, completionBlock: @escaping (_ success: Bool, _ segment: DiscoverViewController.Segment) -> ()) {
    cancelOnGoingRequest()
    loadDiscoverData(for: segment, afterDataEmptied: afterDataEmptied, completionBlock: completionBlock)
  }
  
  func loadDataIfNeeded(for segment: DiscoverViewController.Segment, afterDataEmptied: (() -> ())? = nil, completionBlock: @escaping (_ success: Bool, _ segment: DiscoverViewController.Segment) -> ()) {
    guard dataCount(for: segment) > 0 else {
      if identifiers(for: segment).count == 0 {
        loadDiscoverData(for: segment, afterDataEmptied: afterDataEmptied, completionBlock: completionBlock)
      } else {
        setupPaginators(for: segment)
        loadNextPage(for: segment, completionBlock: completionBlock)
      }
      return
    }

    completionBlock(true, segment)
  }

  private func loadDiscoverData(for segment: DiscoverViewController.Segment, afterDataEmptied: (() -> ())? = nil, completionBlock: @escaping (_ success: Bool, _ segment: DiscoverViewController.Segment) -> ()) {
    cancellableRequest = DiscoverAPI.discover { (success, curatedCollection, error) in
      guard let sections = curatedCollection?.sections else {
        completionBlock(false, segment)
        return
      }
      
      if let featuredContent = sections.featuredContent {
        self.contentIdentifiers = featuredContent
      }
      if let booksIdentifiers = sections.booksIdentifiers {
        self.booksIdentifiers = booksIdentifiers
      }
      if let pagesIdentifiers = sections.pagesIdentifiers {
        self.pagesIdentifiers = pagesIdentifiers
      }
      //Reset data
      self.clearData()
      afterDataEmptied?()
      self.setupPaginators()
      self.cancelOnGoingRequest()
      self.loadNextPage(for: segment,completionBlock: completionBlock)
    }
  }

  func loadNextPage(for segment: DiscoverViewController.Segment, completionBlock: @escaping (_ success: Bool, _ segment: DiscoverViewController.Segment) -> ()) {
    if let listOfIdentifiers = self.nextPageIds(for: segment) {
      cancellableRequest = loadBatch(listOfIdentifiers: listOfIdentifiers, completion: { (success: Bool, resources: [Resource]?, error: BookwittyAPIError?) in
        defer {
          completionBlock(success, segment)
        }
        if let resources = resources, success {
          DataManager.shared.update(resources: resources)
          self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.discover)

          self.updateData(for: segment, with: resources)
        }
      })
    } else {
      completionBlock(false, segment)
    }
  }

  private func loadBatch(listOfIdentifiers: [String], completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: listOfIdentifiers, completion: {
      (success, resource, error) in
      var resources: [Resource]?
      defer {
        completion(success, resources, error)
      }

      guard success, let result = resource else {
        return
      }
      resources = result
    })
  }

  func indexPathForAffectedItems(for segment: DiscoverViewController.Segment, resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(for: segment, index: indexPath.row) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return resourcesIdentifiers.contains(identifier)
    })
  }

  func deleteResource(with identifier: String) {
    if let contentIdIndex = contentIdentifiers.index(where: { $0 == identifier }) {
      contentIdentifiers.remove(at: contentIdIndex)
    }

    if let booksIdIndex = booksIdentifiers.index(where: { $0 == identifier }) {
      booksIdentifiers.remove(at: booksIdIndex)
    }

    if let pagesIdIndex = pagesIdentifiers.index(where: { $0 == identifier }) {
      pagesIdentifiers.remove(at: pagesIdIndex)
    }

    if let contentIndex = contentData.index(where: { $0 == identifier }) {
      contentData.remove(at: contentIndex)
    }

    if let booksIndex = booksData.index(where: { $0 == identifier }) {
      booksData.remove(at: booksIndex)
    }

    if let pagesIndex = pagesData.index(where: { $0 == identifier }) {
      pagesData.remove(at: pagesIndex)
    }
  }
}

// MARK: - Segments Helper
extension DiscoverViewModel {
  func setupPaginators(for segment: DiscoverViewController.Segment? = nil) {
    if let segment = segment {
      switch segment {
      case .content:
        self.contentPaginator = Paginator(ids: contentIdentifiers)
      case .books:
        self.booksPaginator = Paginator(ids: booksIdentifiers)
      case .pages:
        self.pagesPaginator = Paginator(ids: pagesIdentifiers)
      default:
        return
      }
    }else {
      self.contentPaginator = Paginator(ids: contentIdentifiers)
      self.booksPaginator = Paginator(ids: booksIdentifiers)
      self.pagesPaginator = Paginator(ids: pagesIdentifiers)
    }
  }

  func nextPageIds(for segment: DiscoverViewController.Segment) -> [String]? {
    switch segment {
    case .content:
      return self.contentPaginator?.nextPageIds()
    case .books:
      return self.booksPaginator?.nextPageIds()
    case .pages:
      return self.pagesPaginator?.nextPageIds()
    default:
      return nil
    }
  }

  func hasNextPage(for segment: DiscoverViewController.Segment) -> Bool {
    switch segment {
    case .content:
      return self.contentPaginator?.hasMorePages() ?? false
    case .books:
      return self.booksPaginator?.hasMorePages() ?? false
    case .pages:
      return self.pagesPaginator?.hasMorePages() ?? false
    default:
      return false
    }
  }

  fileprivate func identifiers(for segment: DiscoverViewController.Segment) -> [String] {
    //All identifiers for each section - Not effected by the paginator [Paginator uses these lists to paginate]
    switch segment {
    case .content:
      return self.contentIdentifiers
    case .books:
      return self.booksIdentifiers
    case .pages:
      return self.pagesIdentifiers
    default:
      return []
    }
  }

  func data(for segment: DiscoverViewController.Segment) -> [String] {
    //Subset of the identifier, since these array are updated using paginator
    //Display items
    switch segment {
    case .content:
      return self.contentData
    case .books:
      return self.booksData
    case .pages:
      return self.pagesData
    default:
      return []
    }
  }

  func dataCount(for segment: DiscoverViewController.Segment) -> Int {
    let items = data(for: segment)
    return items.count
  }

  func dataItem(for segment: DiscoverViewController.Segment, index: Int) -> String? {
    let items = data(for: segment)
    if items.count > index {
      return items[index]
    }
    return nil
  }

  func clearData(for segment: DiscoverViewController.Segment? = nil) {
    if let segment = segment {
      switch segment {
      case .content:
        self.contentData = []
      case .books:
        self.booksData = []
      case .pages:
        self.pagesData = []
      default:
        return
      }
    } else {
      self.contentData = []
      self.booksData = []
      self.pagesData = []
    }
  }

  fileprivate func updateData(for segment: DiscoverViewController.Segment, with resources: [Resource]) {
    //Get the Initial Order of resources result from the dataIndentifers original ids
    var dataIdentifiers: [String] = []
    for id in identifiers(for: segment) {
      if let index = resources.index(where: { $0.id ?? "" == id }),
        let resId = resources[index].id {
        dataIdentifiers.append(resId)
      }
    }

    switch segment {
    case .content:
      contentData.append(contentsOf: dataIdentifiers)
    case .books:
      booksData.append(contentsOf: dataIdentifiers)
    case .pages:
      pagesData.append(contentsOf: dataIdentifiers)
    default: break
    }
  }
}

// MARK: - Book helper
extension DiscoverViewModel {
  func bookValues(for resource: ModelResource?) -> (identifier: String?, title: String?, author: String?, format: String?, price: String?, imageUrl: String?)? {
    guard let book = resourceFor(id: resource?.id) as? Book else {
      return nil
    }

    return (book.id, book.title, book.productDetails?.author, book.productDetails?.productFormat, book.preferredPrice?.formattedValue, book.thumbnailImageUrl)
  }
}

// MARK: - Collection Helper
extension DiscoverViewModel {
  func numberOfSections() -> Int {
    return DiscoverViewController.Section.numberOfSections
  }

  func numberOfItems(for segment: DiscoverViewController.Segment) -> Int {
    return dataCount(for: segment)
  }

  func resourceForIndex(for segment: DiscoverViewController.Segment, index: Int) -> ModelResource? {
    guard let resourceId = dataItem(for: segment, index: index) else {
      return nil
    }
    return resourceFor(id: resourceId)
  }

  func nodeForItem(for segment: DiscoverViewController.Segment, atIndex index: Int) -> ASCellNode? {
    guard let resource = resourceForIndex(for: segment, index: index) else {
      return nil
    }
    switch (segment) {
    case .pages:
      return PageCellNode()
    case .books:
      return BookNode()
    default:
      let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
      card?.baseViewModel?.resource = resource as? ModelCommonProperties
      return card
    }
  }
}

// MARK: - Posts Actions 
extension DiscoverViewModel {
  func witContent(for segment: DiscoverViewController.Segment, index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = dataItem(for: segment, index: index) else {
      completionBlock(false)
      return
    }

    _ = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.wit)
      }
    })
  }

  func unwitContent(for segment: DiscoverViewController.Segment, index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = dataItem(for: segment, index: index) else {
      completionBlock(false)
      return
    }

    _ = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.unwit)
      }
    })
  }

  func sharingContent(for segment: DiscoverViewController.Segment, index: Int) -> [String]? {
    guard let commonProperties = resourceForIndex(for: segment, index: index) as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}

// MARK: - PenName Follow/Unfollow
extension DiscoverViewModel {
  func follow(for segment: DiscoverViewController.Segment, index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(for: segment, index: index),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      followPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      followRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  func unfollow(for segment: DiscoverViewController.Segment, index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(for: segment, index: index),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      unfollowPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      unfollowRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  fileprivate func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
        penName.following = true
      }
      completionBlock(success)
    }
  }

  fileprivate func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
        penName.following = false
      }
      completionBlock(success)
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
      }
      completionBlock(success)
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
      }
      completionBlock(success)
    }
  }
}

// MARK: - Handle Reading Lists Images
extension DiscoverViewModel {
  func loadReadingListImages(for segment: DiscoverViewController.Segment, at indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = resourceForIndex(for: segment, index: indexPath.item) as? ReadingList,
      let identifier = readingList.id else {
        completionBlock(nil)
        return
    }
    
    let pageSize: String = String(maxNumberOfImages)
    let page: (number: String?, size: String?) = (nil, pageSize)
    _ = GeneralAPI.postsContent(contentIdentifier: identifier, page: page) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if let resources = resources, success {
        var images: [String] = []
        resources.forEach({ (resource) in
          if let res = resource as? ModelCommonProperties {
            if let imageUrl = res.thumbnailImageUrl {
              images.append(imageUrl)
            }
          }
        })
        imageCollection = images
      }
    }
  }
}

// MARK: - Introductory Banner Logic
extension DiscoverViewModel {
  var shouldDisplayIntroductoryBanner: Bool {
    get {
      return GeneralSettings.sharedInstance.shouldDisplayDiscoverIntroductoryBanner
    }
    set {
      GeneralSettings.sharedInstance.shouldDisplayDiscoverIntroductoryBanner = newValue
    }
  }
}
