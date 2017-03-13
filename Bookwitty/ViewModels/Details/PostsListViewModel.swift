//
//  PostsListViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine
import Moya

class PostsListViewModel {
  var data: [Resource] = []
  var paginator: Paginator!
  var cancellableRequest: Cancellable?

  init(ids: [String], preloadedList: [Resource]) {
    let pageSize = 10
    let startPage = 0
    let resourceIdSet = Set(ids)
    let loadedIds: [String] = preloadedList.flatMap { (_ resource: Resource) -> String? in
      return resource.id
    }
    let preloadListSet = Set(loadedIds)
    let result: [String] = Array(resourceIdSet.subtracting(preloadListSet))
    data = preloadedList
    paginator = Paginator(ids: result, pageSize: pageSize, startPage: startPage)
  }

  func hasNextPage() -> Bool {
    return paginator?.hasMorePages() ?? false
  }

  func contentPostsItem(at index: Int) -> Resource? {
    return data[index]
  }

  func contentPostsItemCount() -> Int {
    return data.count
  }

  func loadContentPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let listOfIdentifiers = self.paginator?.nextPageIds() else {
      completionBlock(false)
      return
    }

    cancellableRequest = loadBatch(listOfIdentifiers: listOfIdentifiers, completion: { (success: Bool, resources: [Resource]?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        self.data += resources
      }
    })
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
