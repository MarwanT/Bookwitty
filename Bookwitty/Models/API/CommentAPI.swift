//
//  CommentAPI.swift
//  Bookwitty
//
//  Created by Marwan  on 5/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct CommentAPI {
  public static func comments(postIdentifier: String, completion: @escaping (_ success: Bool, _ comments: [Comment]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let retieveCommentsSuccessStatusCode = 200
    
    return signedAPIRequest(target: .comments(postIdentifier: postIdentifier), completion: {
      (data, statucCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentsArray: [Comment]? = nil
        var completionError: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentsArray, error)
          }
        }
        
        guard let statucCode = statucCode, statucCode == retieveCommentsSuccessStatusCode else {
          completionError = BookwittyAPIError.invalidStatusCode
          return
        }
        
        // Parse Data
        if let data = data, let comments = Comment.parseDataArray(data: data)?.resources {
          commentsArray = comments
          success = true
        } else {
          completionError = BookwittyAPIError.failToParseData
        }
      }
    })
  }
  
  public static func commentReplies(identifier: String, completion: @escaping (_ success: Bool, _ comments: [Comment]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let retieveCommentsSuccessStatusCode = 200
    
    return signedAPIRequest(target: .replies(commentIdentifier: identifier), completion: {
      (data, statucCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentsArray: [Comment]? = nil
        var completionError: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentsArray, error)
          }
        }
        
        guard let statucCode = statucCode, statucCode == retieveCommentsSuccessStatusCode else {
          completionError = BookwittyAPIError.invalidStatusCode
          return
        }
        
        // Parse Data
        if let data = data, let comments = Comment.parseDataArray(data: data)?.resources {
          commentsArray = comments
          success = true
        } else {
          completionError = BookwittyAPIError.failToParseData
        }
      }
    })
  }
}

extension CommentAPI {
  static func createCommentBody(comment: String, parentCommentIdentifier: String?) -> [String : Any]? {
    var attributes = ["body" : comment]
    if let parentCommentIdentifier = parentCommentIdentifier {
      attributes["parent-id"] = parentCommentIdentifier
    }
    
    let dictionary = [
      "data" : [
        "attributes" : attributes
      ]
    ]
    return dictionary
  }
}
