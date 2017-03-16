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

  func search(query: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    self.data.removeAll(keepingCapacity: false)

    cancellableRequest = SearchAPI.search(filter: (query, nil), page: nil, completion: {
      (success, resources, nextPage, error) in
      guard success, let resources = resources else {
        completion(success, error)
        return
      }

      let resourceIds: [String] = resources.flatMap({ $0.id })
      self.cancellableRequest = self.loadBatch(listOfIdentifiers: resourceIds, completion: { (success, resources, error) in
        defer {
          completion(success, error)
        }
        guard success, let resources = resources else {
          return
        }
        self.data += resources
      })
    })
  }

  private func loadBatch(listOfIdentifiers: [String], completion: @escaping (_ success: Bool, _ resources: [ModelResource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: listOfIdentifiers, completion: {
      (success, resource, error) in
      var resources: [ModelResource]?
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
