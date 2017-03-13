//
//  PostsListViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

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

}
