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
  public static func feed(completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.newsFeed()) {
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

      // Parse Data
      guard let data = data,
        let parsedData = Parser.parseDataArray(data: data) else {
          return
      }

      resources = parsedData.resources
      success = parsedData.resources != nil
      completionError = nil
      nextPage = parsedData.next
    }
  }

  public static func nextFeedPage(nextPage: URL, completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
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

  public static func wit(contentId: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let witSuccessStatusNoContent = 204

    return signedAPIRequest(target: BookwittyAPI.wit(contentId: contentId), completion: { (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      defer {
        completion(success, error)
      }

      // If status code is not available then break
      guard let statusCode = statusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // If status code != success then break
      if statusCode != witSuccessStatusNoContent {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = statusCode == witSuccessStatusNoContent
    })
  }

  public static func unwit(contentId: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let unwitSuccessStatusNoContent = 204
    let unwitSuccessStatusAlreadyDeleted = 404

    return signedAPIRequest(target: BookwittyAPI.unwit(contentId: contentId), completion: { (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      defer {
        completion(success, error)
      }

      // If status code is not available then break
      guard let statusCode = statusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // If status code != success then break
      if statusCode != unwitSuccessStatusNoContent && statusCode != unwitSuccessStatusAlreadyDeleted {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = (statusCode == unwitSuccessStatusNoContent || statusCode == unwitSuccessStatusAlreadyDeleted)
    })
  }
}
