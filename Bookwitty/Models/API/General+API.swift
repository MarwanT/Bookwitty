//
//  General+API.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

struct GeneralAPI {
  public static func nextPage(nextPage: URL, completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.absolute(url: nextPage)) {
      (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      var resources: [Resource]?
      var nextPage: URL?
      defer {
        completion(success, resources, nextPage, error)
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
        // Parse Data
        guard let data = data,
          let parsedData = Parser.parseDataArray(data: data) else {
            return
        }
        //TODO: handle parsedData.next and parsedData.errors if any
        
        resources = parsedData.resources
        success = parsedData.resources != nil
        completionError = nil
        nextPage = parsedData.next
      }
    }
  }
}
