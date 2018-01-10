//
//  Tag+API.swift
//  Bookwitty
//
//  Created by ibrahim on 10/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Moya

public struct TagAPI {
  
  func linkTag(for contentIdentifier: String, with tagIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 204
    return signedAPIRequest(target: .linkTag(contentIdentifier: contentIdentifier, tagIdentifier: tagIdentifier), completion: { (data, statusCode, response, error) in
        var success: Bool = false
        var error: BookwittyAPIError? = nil
        defer {
          completion(success, error)
        }
        guard data != nil, let statusCode = statusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        success = statusCode == successStatusCode
      })
  }
}

extension TagAPI {
  static func linkTag(_ identifier: String) -> [String:Any]? {
    let dictionary = [
      "data" : [
        "attributes" : [
          "type" : Tag.resourceType,
          "id" : identifier,
        ]
      ]
    ]
    return dictionary
  }
}
