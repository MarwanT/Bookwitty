//
//  Content+API.swift
//  Bookwitty
//
//  Created by Marwan  on 6/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

struct ContentAPI {
  static func editions(contentIdentifier identifier: String, formats: [String]?, completion: @escaping (_ success: Bool, _ resource: [ModelResource]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200
    
    return signedAPIRequest(target: .editions(identifier: identifier, formats: formats), completion: {
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
  
  static func preferredFormats(identifier: String, completion: @escaping (_ success: Bool, _ resources: [Book]?, _ metadata: Book.Meta?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200
    
    return signedAPIRequest(target: .preferredFormats(bookIdentifier: identifier), completion: {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var books: [Book]? = nil
      var error: BookwittyAPIError? = error
      var bookMeta: Book.Meta? = nil
      
      defer {
        completion(success, books, bookMeta, error)
      }
      
      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
      
      guard let data = data, let values = Parser.parseDataArray(data: data), let bookResources = values.resources as? [Book] else {
        error = BookwittyAPIError.failToParseData
        return
      }
      
      books = bookResources
      bookMeta = Book.Meta(dictionary: values.metadata)
    })
  }

  static func report(identifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 204

    return signedAPIRequest(target: .report(identifier: identifier), completion: {
      (data, statusCode, response, error) in
      let success: Bool = statusCode == successStatusCode
      var error: BookwittyAPIError? = error

      defer {
        completion(success, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
    })
  }
  
  static func linkContent(for contentIdentifier: String, with topicIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 204
    return signedAPIRequest(target: .linkContent(contentIdentifier: contentIdentifier, topicIdentifier: topicIdentifier), completion: { (data, statusCode, response, error) in
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
  
  static func unlinkContent(for contentIdentifier: String, with topicIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 204
    return signedAPIRequest(target: .unlinkContent(contentIdentifier: contentIdentifier, topicIdentifier: topicIdentifier), completion: { (data, statusCode, response, error) in
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

extension ContentAPI {
  static func editionsFilterParameters(formats: [String]?) -> [String : Any]? {
    var dictionary = [String : Any]()
    if let formats = formats {
      dictionary["filter[formats]"] = formats
    }
    return dictionary
  }
  
  static func linkContentParameters(_ identifier: String) -> [String:Any]? {
    let dictionary = [
      "data" : [[
          "type" : Topic.resourceType,
          "id" : identifier,
          ]
      ]
    ]
    return dictionary
  }
  
  static func unlinkContentParameters(_ identifier: String) -> [String:Any]? {
    let dictionary = [
      "data" : [[
        "type" : Topic.resourceType,
        "id" : identifier,
        ]
      ]
    ]
    return dictionary
  }
}
