//
//  Newsfeed+API.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

struct NewsfeedAPI {
  public static func feed(completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.newsFeed()) {
      (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      var resources: [Resource]?
      defer {
        completion(success, resources, error)
      }

      // If status code is not available then break
      guard let statusCode = statusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // If status code != success then break
      if statusCode != 200 {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // Retrieve Dictionary from data
      do {
        guard let data = data else {
          return
        }
        // Parse Data
        resources = Parser.parseDataArray(data: data)
        success = true
        completionError = nil
      }
    }
  }
}
