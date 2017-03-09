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
          self.data += resources
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
    return data.count > 0 ? 1 : 0
  }

  func numberOfItemsInSection() -> Int {
    return data.count
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
    return CardFactory.shared.createCardFor(resource: resource)
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

  func sharingContent(index: Int) -> String? {
    guard data.count > index,
      let commonProperties = data[index] as? ModelCommonProperties else {
        return nil
    }

    let content = data[index]
    //TODO: Make sure that we are sharing the right information
    let shortDesciption = commonProperties.shortDescription ?? commonProperties.title ?? ""
    if let sharingUrl = content.url {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return sharingString
    }

    //TODO: Remove dummy data and return nil instead since we do not have a url to share.
    var sharingString = "https://bookwitty-api-qa.herokuapp.com/reading_list/ios-mobile-applications-development/58a6f9b56b2c581af13637f6"
    sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
    return sharingString
  }
}
