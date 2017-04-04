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
  var cancellableRequest: Cancellable?
  var nextPage: URL?

  init(nextPage: URL?, preloadedList: [Resource]) {
    self.nextPage = nextPage
    data = preloadedList
  }

  func hasNextPage() -> Bool {
    return nextPage != nil
  }

  func contentPostsItem(at index: Int) -> Resource? {
    return data[index]
  }

  func contentPostsItemCount() -> Int {
    return data.count
  }

  func loadContentPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      return
    }

    cancellableRequest = GeneralAPI.nextPage(nextPage: nextPage, completion: { (success, resources, next, error) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        self.data += resources
        self.nextPage = next
      }
    })
  }
}
