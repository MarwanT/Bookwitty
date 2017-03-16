//
//  SearchViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class SearchViewModel {
  var data: [ModelResource] = []
  var cancellableRequest: Cancellable?
  var nextPage: URL?

  func cancelActiveRequest() {
    guard let cancellableRequest = cancellableRequest else {
      return
    }
    if !cancellableRequest.isCancelled {
      cancellableRequest.cancel()
    }
  }

  func search(query: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    //Cancel any on-goin request
    cancelActiveRequest()

    self.data.removeAll(keepingCapacity: false)

    cancellableRequest = SearchAPI.search(filter: (query, nil), page: nil, completion: {
      (success, resources, nextPage, error) in
      guard success, let resources = resources else {
        completion(success, error)
        return
      }

      self.data += resources
      self.nextPage = nextPage
      completion(success, error)
    })
  }

  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completionBlock(false)
      return
    }
    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = GeneralAPI.nextPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        self.data += resources
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
      completionBlock(success)
    }
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }
}

// Mark: - Collection helper
extension SearchViewModel {
  func numberOfSections() -> Int {
    return SearchViewController.Section.numberOfSections
  }

  func numberOfItemsInSection(section: Int) -> Int {
    return SearchViewController.Section.activityIndicator.rawValue == section ? 1 : data.count
  }

  func resourceForIndex(indexPath: IndexPath) -> ModelResource? {
    guard data.count > indexPath.row else { return nil }
    let resource = data[indexPath.row]
    return resource
  }

  func nodeForItem(atIndexPath indexPath: IndexPath) -> BaseCardPostNode? {
    guard let resource = resourceForIndex(indexPath: indexPath) else {
      return nil
    }

    return CardFactory.shared.createCardFor(resource: resource)
  }
}

// Mark: - Reading List
extension SearchViewModel {
  func loadReadingListImages(atIndexPath indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = resourceForIndex(indexPath: indexPath) as? ReadingList else {
      completionBlock(nil)
      return
    }
    var ids: [String] = []
    if let list = readingList.postsRelations {
      for item in list {
        ids.append(item.id)
      }
    }
    if ids.count > 0 {
      let limitToMaximumIds = Array(ids.prefix(maxNumberOfImages))
      loadReadingListItems(readingListIds: limitToMaximumIds, completionBlock: completionBlock)
    } else {
      completionBlock(nil)
    }
  }

  private func loadReadingListItems(readingListIds: [String], completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    _ = UserAPI.batch(identifiers: readingListIds) { (success, resources, error) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if success {
        var images: [String] = []
        resources?.forEach({ (resource) in
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

// MARK: - Posts Actions
extension SearchViewModel {
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func sharingContent(indexPath: IndexPath) -> [String]? {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let commonProperties = resource as? ModelCommonProperties else {
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
extension SearchViewModel {
  func follow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
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

  func unfollow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
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

  func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    followRequest(identifier: identifier) {
      (success: Bool) in
      defer {
        completionBlock(success)
      }
      penName.following = true
    }
  }

  func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    unfollowRequest(identifier: identifier) {
      (success: Bool) in
      defer {
        completionBlock(success)
      }
      penName.following = false
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }
}

