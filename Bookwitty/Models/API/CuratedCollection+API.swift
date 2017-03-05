//
//  CuratedCollection+API.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct CuratedCollectionAPI {
  static func storeFront(completion: @escaping (_ success: Bool, _ collection: CuratedCollection?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.bookStore, completion: {
      (data, statucCode, response, error) in
      var success: Bool = false
      var collection: CuratedCollection? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, collection, error)
      }
      
      if let data = data {
        collection = CuratedCollection.parseData(data: data)
        success = collection != nil
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }
}
