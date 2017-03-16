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
      completion(success, error)
    })
  }
}
