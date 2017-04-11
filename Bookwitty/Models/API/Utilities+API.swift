//
//  Utilities+API.swift
//  Bookwitty
//
//  Created by charles on 3/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct UtilitiesAPI {
  static func upload(url: URL, paramters: [String : String], multipart: (data: Data, name: String), completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 204
    let apiRequest = createAPIRequest(target: .uploadMultipart(url: url, parameters: paramters, multipart: multipart), completion: {
      (data, statusCode, response, error) in
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
    return apiRequest()
  }
}
