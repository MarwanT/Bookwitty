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
    return 1
  }

  func numberOfItemsInSection() -> Int {
    return data.count
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
