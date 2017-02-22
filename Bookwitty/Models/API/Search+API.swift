//
//  Search+API.swift
//  Bookwitty
//
//  Created by charles on 2/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Moya

struct SearchAPI {
  static func search(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?, completion: @escaping (_ success: Bool, _ collection: [ModelResource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.Search(filter: filter, page: page)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var collection: [ModelResource]? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, collection, error)
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }
      // Parse Data
      collection = Parser.parseDataArray(data: data)
      success = true
      error = nil
    }
  }
}
