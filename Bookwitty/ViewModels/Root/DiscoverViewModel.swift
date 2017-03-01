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

  func loadDiscoverData(completionBlock: @escaping (_ success: Bool) -> ()) {
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
    //TODO: load Next Page
    defer {
      completionBlock(success)
    }
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

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard data.count > index else { return nil }
    let resource = data[index]
    return CardRegistry.getCard(resource: resource)
  }
}
