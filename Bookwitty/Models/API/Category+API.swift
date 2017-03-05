//
//  Category+API.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct CategoryAPI {
  static func categoryCuratedContent(categoryIdentifier: String, completion: @escaping (_ success: Bool, _ collection: CuratedCollection?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: .categoryCuratedContent(categoryIdentifier: categoryIdentifier), completion: {
      (data, statusCode, response, error) in
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
