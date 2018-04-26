//
//  Tag+API.swift
//  Bookwitty
//
//  Created by ibrahim on 10/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Moya

public struct TagAPI {
  
  static func removeTag(for contentIdentifier: String, with tagIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 204
    return signedAPIRequest(target: .removeTag(contentIdentifier: contentIdentifier, tagIdentifier: tagIdentifier), completion: { (data, statusCode, response, error) in
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
  
  static func replaceTags(for contentIdentifier: String, with tags: [String]?, status: PublishAPI.PublishStatus?, completion: @escaping (_ success: Bool, _ candidatePost: CandidatePost?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 200
    return signedAPIRequest(target: .replaceTags(contentIdentifier: contentIdentifier, tags: tags, status: status), completion: { (data, statusCode, response, error) in
      var success: Bool = false
      var error: BookwittyAPIError? = nil
      var post: CandidatePost? = nil
      defer {
        completion(success, post, error)
      }
      
      guard let statusCode = statusCode, statusCode == successStatusCode else {
        guard let data = data else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        if ErrorManager.shared.maxTagsAllowed(data: data).hasError {
          error = BookwittyAPIError.maxTagsAllowed
        }
        return
      }
      
      guard let data = data else {
        error = BookwittyAPIError.undefined
        return
      }
      
      success = statusCode == successStatusCode
      post = Text.parseData(data: data) as? CandidatePost

    })
  }

}

extension TagAPI {
  static func linkTagParameters(_ identifier: String, title: String) -> [String:Any]? {
    let dictionary = [
      "data" : [[
        "attributes": [
          "title": title,
        ],
        "type" : Tag.resourceType,
        "id" : identifier,
        ]
      ]
    ]
    return dictionary
  }
  
  static func removeTagParameters(_ identifier: String) -> [String:Any]? {
    let dictionary = [
      "data" : [[
        "type" : Tag.resourceType,
        "id" : identifier,
        ]
      ]
    ]
    return dictionary
  }
  
  static func replaceTagsParameters(tags: [String]?, status: PublishAPI.PublishStatus?) -> [String : Any]? {
    let dictionary = [
      "data" : [
        "attributes" : [
          "tag-titles" : tags,
          "status": status?.rawValue,
        ]
      ]
    ]
    return dictionary
  }
}
