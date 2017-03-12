//
//  Discover+API.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct DiscoverAPI {
  static func discover(completion: @escaping (_ success: Bool, _ collection: CuratedCollection?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.discover, completion: {
      (data, statucCode, response, error) in
      var success: Bool = false
      var collection: CuratedCollection? = nil
      var error: BookwittyAPIError? = nil
      DispatchQueue.global(qos: .background).async {
        defer {
          DispatchQueue.main.async {
            completion(success, collection, error)
          }
        }

        if let data = data {
          collection = CuratedCollection.parseData(data: data)
          success = collection != nil
        } else {
          error = BookwittyAPIError.failToParseData
        }
      }
    })
  }
}
