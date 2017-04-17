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

final class DiscoverViewModel {
  var cancellableRequest:  Cancellable?
  var dataIdentifiers: [String] = []
  var data: [ModelResource] = []
  var paginator: Paginator?

  func cancellableOnGoingRequest() {
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }
  }

  func loadDiscoverData(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableOnGoingRequest()

    cancellableRequest = DiscoverAPI.discover { (success, curatedCollection, error) in
      guard let sections = curatedCollection?.sections else {
        completionBlock(false)
        return
      }
      //Note: We may need Add booksIdentifiers and readingListIdentifiers later
      if let featuredContent = sections.featuredContent {
        self.dataIdentifiers = featuredContent
      }
      //Reset data
      self.data = []
      self.paginator = Paginator(ids: self.dataIdentifiers)
      self.loadNextPage(completionBlock: completionBlock)
    }
  }

  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    if let listOfIdentifiers = self.paginator?.nextPageIds() {
      cancellableOnGoingRequest()
      cancellableRequest = loadBatch(listOfIdentifiers: listOfIdentifiers, completion: { (success: Bool, resources: [Resource]?, error: BookwittyAPIError?) in
        defer {
          completionBlock(success)
        }
        if let resources = resources, success {
          //Get the Initial Order of resources result from the dataIndentifers original ids
          for id in self.dataIdentifiers {
            if let index = resources.index(where: { $0.id ?? "" == id }) {
              self.data.append(resources[index])
            }
          }
        }
      })
    } else {
      completionBlock(false)
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
}

// MARK: - Collection Helper
extension DiscoverViewModel {
  func hasNextPage() -> Bool {
    return paginator?.hasMorePages() ?? false
  }

  func numberOfSections() -> Int {
    return DiscoverViewController.Section.numberOfSections
  }

  func numberOfItemsInSection(section: Int) -> Int {
    return DiscoverViewController.Section.cards.rawValue == section ? data.count : 1
  }

  func resourceForIndex(index: Int) -> ModelResource? {
    guard data.count > index else { return nil }
    let resource = data[index]
    return resource
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = resourceForIndex(index: index) else {
      return nil
    }
    return CardFactory.createCardFor(resource: resource)
  }
}

// MARK: - Posts Actions 
extension DiscoverViewModel {
  func witContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard data.count > index,
      let contentId = data[index].id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard data.count > index,
      let contentId = data[index].id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func sharingContent(index: Int) -> [String]? {
    guard data.count > index,
      let commonProperties = data[index] as? ModelCommonProperties else {
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
  func follow(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
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

  func unfollow(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
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

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
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

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
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

// MARK: - Handle Reading Lists Images
extension DiscoverViewModel {
  func loadReadingListImages(at indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = data[indexPath.item] as? ReadingList else {
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

//MARK: - Analytics
extension DiscoverViewModel {
  func resource(at index: Int) -> ModelResource? {
    guard let resource = resourceForIndex(index: index) else {
        return nil
    }

    return resource
  }
}

