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

  private func search(query: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    self.data.removeAll(keepingCapacity: false)

    cancellableRequest = SearchAPI.search(filter: (query, nil), page: nil, completion: {
      (success, resources, nextPage, error) in
      defer {
        completion(success, error)
      }

      guard success, let resources = resources else {
        return
      }
      self.data += resources
    })
  }
}
