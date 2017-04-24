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

  static func content<T: Resource>(of identifier: String, include: [String]?, completion: @escaping (_ success: Bool, _ resource: T?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? where T: Parsable {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: .content(identifier: identifier, include: include), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var resource: T? = nil
      var error: BookwittyAPIError? = error

      defer {
        completion(success, resource, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      resource = T.parseData(data: data) as? T
    })
  }

  static func postsContent(contentIdentifier identifier: String, page: (number: String?, size: String?)?, completion: @escaping (_ success: Bool, _ resource: [ModelResource]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: .postsContent(identifier: identifier, page: page), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var resources: [ModelResource]? = nil
      var error: BookwittyAPIError? = error
      var next: URL? = nil

      defer {
        completion(success, resources, next, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      let values = Parser.parseDataArray(data: data)

      resources = values?.resources
      next = values?.next
    })
  }

  static func posts(contentIdentifier identifier: String, type: [String]?, completion: @escaping (_ success: Bool, _ resource: [ModelResource]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: .posts(identifier: identifier, type: type), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var resources: [ModelResource]? = nil
      var error: BookwittyAPIError? = error
      var next: URL? = nil

      defer {
        completion(success, resources, next, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      let values = Parser.parseDataArray(data: data)

      resources = values?.resources
      next = values?.next
    })
  }

  static func postsLinkedContent(contentIdentifier identifier: String, type: [String]?, completion: @escaping (_ success: Bool, _ resource: [ModelResource]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: .postsLinkedContent(identifier: identifier, type: type), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var resources: [ModelResource]? = nil
      var error: BookwittyAPIError? = error
      var next: URL? = nil

      defer {
        completion(success, resources, next, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      let values = Parser.parseDataArray(data: data)

      resources = values?.resources
      next = values?.next
    })
  }


  static func editions(contentIdentifier identifier: String, completion: @escaping (_ success: Bool, _ resource: [ModelResource]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: .editions(identifier: identifier), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var resources: [ModelResource]? = nil
      var next: URL? = nil
      var error: BookwittyAPIError? = error

      defer {
        completion(success, resources, next, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      let values = Parser.parseDataArray(data: data)
      resources = values?.resources
      next = values?.next
    })
  }

  static func follow(identifer: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {

    let successStatusCode = 204

    return signedAPIRequest(target: .follow(identifier: identifer), completion: {
      (data, statusCode, response, error) in
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
      if statusCode != successStatusCode {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = statusCode == successStatusCode
    })
  }

  static func unfollow(identifer: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let unfollowSuccessStatusNoContent = 204
    let unfollowSuccessStatusAlreadyDeleted = 404

    return signedAPIRequest(target: .unfollow(identifier: identifer), completion: {
      (data, statusCode, response, error) in
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
      if statusCode != unfollowSuccessStatusNoContent && statusCode != unfollowSuccessStatusAlreadyDeleted {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = (statusCode == unfollowSuccessStatusNoContent || statusCode == unfollowSuccessStatusAlreadyDeleted)
    })
  }

  static func followPenName(identifer: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {

    let successStatusCode = 204

    return signedAPIRequest(target: .followPenName(identifier: identifer), completion: {
      (data, statusCode, response, error) in
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
      if statusCode != successStatusCode {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = statusCode == successStatusCode
    })
  }

  static func unfollowPenName(identifer: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let unfollowSuccessStatusNoContent = 204
    let unfollowSuccessStatusAlreadyDeleted = 404

    return signedAPIRequest(target: .unfollowPenName(identifier: identifer), completion: {
      (data, statusCode, response, error) in
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
      if statusCode != unfollowSuccessStatusNoContent && statusCode != unfollowSuccessStatusAlreadyDeleted {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      success = (statusCode == unfollowSuccessStatusNoContent || statusCode == unfollowSuccessStatusAlreadyDeleted)
    })
  }

  static func status(completion: @escaping (_ success: Bool, _ appMeta: AppMeta?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return apiRequest(target: .status, completion: {
      (data, statusCode, response, error) in
      var success = false
      var meta: AppMeta? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, meta, error)
      }
      
      guard let data = data else {
        return
      }
      
      meta = AppMeta.appMeta(for: data)
      success = meta != nil
    })
  }
  
  static func sendAccountConfirmation(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let senAccountConfirmationSuccess = 204
    
    return signedAPIRequest(target: .resendAccountConfirmation, completion: {
      (data, statusCode, response, error) in
      guard let statusCode = statusCode, statusCode == senAccountConfirmationSuccess else {
        completion(false, error)
        return
      }
      completion(true, nil)
    })
  }
}

extension GeneralAPI {
  static func postsParameters(type: [String]?) -> [String : Any]? {
    var dictionary = [String : Any]()

    //Filters
    if let type = type {
      dictionary["filter[types]"] = type
    }

    return dictionary
  }

  static func postsContentParameters(page: (number: String?, size: String?)?) -> [String : Any]? {
    var dictionary = [String : Any]()
    //Pagination
    if let page = page {
      if let number = page.number {
        dictionary["page[number]"] = number
      }

      if let size = page.size {
        dictionary["page[size]"] = size
      }
    }
    return dictionary
  }
}
