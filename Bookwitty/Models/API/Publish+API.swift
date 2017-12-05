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
  
  static func createContent(title: String?, body: String?, completion: @escaping (_ success: Bool, _ candidatePost: CandidatePost?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 201
    return signedAPIRequest(target: BookwittyAPI.createContent(title: title, body: body, status: .draft), completion: { (data, statusCode, response, error) in
      var success: Bool = false
      var error: BookwittyAPIError? = nil
      var post: CandidatePost? = nil
      defer {
        completion(success, post, error)
      }
      guard data != nil, let statusCode = statusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
      success = statusCode == successStatusCode
      
      post = Text.parseData(data: data) as? CandidatePost
    })
  }

  static func updateContent(id: String, title: String?, body: String?, imageURL: String?, shortDescription: String?, status: PublishStatus? = .draft, completion: @escaping (_ success: Bool, _ candidatePost: CandidatePost?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200
    return signedAPIRequest(target: BookwittyAPI.updateContent(id: id, title: title, body: body, imageURL: imageURL, shortDescription: shortDescription, status: status), completion: { (data, statusCode, response, error) in
      var success: Bool = false
      var error: BookwittyAPIError? = nil
      var post: CandidatePost? = nil
      defer {
        completion(success, post, error)
      }
      guard data != nil, let statusCode = statusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
        
      }
      success = statusCode == successStatusCode
      post = Text.parseData(data: data) as? CandidatePost
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
  static func createContentParameters(title: String?, body: String?, status: PublishStatus) -> [String : Any]? {
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
  static func updateContentParameters(title: String?, body: String?, imageURL: String?, shortDescription: String?, status: PublishStatus?) -> [String : Any]? {
    
    var attributes = [String : String]()
    
    if let title = title {
      attributes["title"] = title
    }
    
    if let body = body {
      attributes["body"] = body
    }
    
    if let shortDescription = shortDescription {
      attributes["short-description"] = shortDescription
    }
    
    if let imageURL = imageURL {
      attributes["cover-image-url"] = imageURL
    }
    
    if let status = status {
      attributes["status"] = status.rawValue
    }
    
    let dictionary = [
      "data" : [
        "attributes" : attributes
      ]
    ]
    return dictionary
  }

}
