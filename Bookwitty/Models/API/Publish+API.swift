//
//  Publish+API.swift
//  Bookwitty
//
//  Created by ibrahim on 10/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

public struct PublishAPI {
  public enum PublishStatus: String {
    case draft = "draft"
    case `public` = "public"
  }
  
  static func createContent(title: String, body: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200
    return signedAPIRequest(target: BookwittyAPI.createContent(title: title, body: body, status: .draft), completion: { (data, statusCode, response, error) in
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

  static func removeContent(contentIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 204
    return signedAPIRequest(target: BookwittyAPI.removeContent(contentIdentifier:contentIdentifier), completion: { (data, statusCode, response, error) in
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

extension PublishAPI {
  static func createContentParameters(title: String, body: String, status: PublishStatus) -> [String : Any]? {
    let dictionary = [
      "data" : [
        "type": "texts",
        "attributes" : [
          "title" : title,
          "body" : body,
          "status": status.rawValue,
        ]
      ]
    ]
    return dictionary
  }
}
