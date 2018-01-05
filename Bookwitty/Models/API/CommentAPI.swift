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
  public static func comments(postIdentifier: String, completion: @escaping (_ success: Bool, _ comments: [Comment]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let retieveCommentsSuccessStatusCode = 200
    
    return signedAPIRequest(target: .comments(postIdentifier: postIdentifier), completion: {
      (data, statucCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentsArray: [Comment]? = nil
        var next: URL? = nil
        var completionError: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentsArray, next, error)
          }
        }
        
        guard let statucCode = statucCode, statucCode == retieveCommentsSuccessStatusCode else {
          completionError = BookwittyAPIError.invalidStatusCode
          return
        }
        
        // Parse Data
        if let data = data, let parsedData = Comment.parseDataArray(data: data), let comments = parsedData.resources {
          commentsArray = comments
          success = true
          
          if let nextURL = parsedData.next {
            next = nextURL
          }
        } else {
          completionError = BookwittyAPIError.failToParseData
        }
      }
    })
  }
  
  public static func commentReplies(identifier: String, completion: @escaping (_ success: Bool, _ comments: [Comment]?, _ next: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let retieveCommentsSuccessStatusCode = 200
    
    return signedAPIRequest(target: .replies(commentIdentifier: identifier), completion: {
      (data, statucCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentsArray: [Comment]? = nil
        var next: URL? = nil
        var completionError: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentsArray, next, error)
          }
        }
        
        guard let statucCode = statucCode, statucCode == retieveCommentsSuccessStatusCode else {
          completionError = BookwittyAPIError.invalidStatusCode
          return
        }
        
        // Parse Data
        if let data = data, let parsedData = Comment.parseDataArray(data: data), let comments = parsedData.resources {
          commentsArray = comments
          commentsArray?.forEach({ $0.parentId = identifier })
          success = true
          
          if let nextURL = parsedData.next {
            next = nextURL
          }
        } else {
          completionError = BookwittyAPIError.failToParseData
        }
      }
    })
  }
  
  public static func createComment(postIdentifier: String, commentMessage: String, parentCommentIdentifier: String?, completion: @escaping (_ success: Bool, _ comment: Comment?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let createCommentsSuccessStatusCode = 201
    
    return signedAPIRequest(target: .createComment(postIdentifier: postIdentifier, comment: commentMessage, parentCommentIdentifier: parentCommentIdentifier), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var comment: Comment? = nil
      var completionError: BookwittyAPIError? = error
      defer {
        DispatchQueue.main.async {
          completion(success, comment, error)
        }
      }
      
      guard let statucCode = statusCode, statucCode == createCommentsSuccessStatusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }
      
      // Parse Data
      if let data = data, let newComment = Comment.parseData(data: data) {
        comment = newComment
        comment?.parentId = parentCommentIdentifier
        // The pen name is set explicitly here because the API does not get it back
        comment?.penName = UserManager.shared.defaultPenName
        success = true
      } else {
        completionError = BookwittyAPIError.failToParseData
      }
    })
  }
  
  public static func removeComment(commentIdentifier: String, completion: @escaping (_ success: Bool, _ commentIdentifier: String, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let removeCommentsSuccessStatusCode = 204
    
    return signedAPIRequest(target: .removeComment(commentId: commentIdentifier), completion: {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentIdentifier = commentIdentifier
        var error: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentIdentifier, error)
          }
        }
        
        guard statusCode == removeCommentsSuccessStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        
        success  = true
      }
    })
  }
  
  public static func wit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ commentIdentifier: String, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let witCommentSuccessfulStatusCode = 204
    
    return signedAPIRequest(target: .witComment(identifier: commentIdentifier), completion: {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentIdentifier = commentIdentifier
        var error: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentIdentifier, error)
          }
        }
        
        guard statusCode == witCommentSuccessfulStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        
        success  = true
      }
    })
  }
  
  public static func unwit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ commentIdentifier: String, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let unwitCommentSuccessfulStatusCode = 204
    
    return signedAPIRequest(target: .unwitComment(identifier: commentIdentifier), completion: {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentIdentifier = commentIdentifier
        var error: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentIdentifier, error)
          }
        }
        
        guard statusCode == unwitCommentSuccessfulStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        
        success  = true
      }
    })
  }
  
  public static func dim(commentIdentifier: String, completion: @escaping (_ success: Bool, _ commentIdentifier: String, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let dimCommentSuccessfulStatusCode = 204
    
    return signedAPIRequest(target: .dimComment(identifier: commentIdentifier), completion: {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentIdentifier = commentIdentifier
        var error: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentIdentifier, error)
          }
        }
        
        guard statusCode == dimCommentSuccessfulStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        
        success  = true
      }
    })
  }
  
  public static func undim(commentIdentifier: String, completion: @escaping (_ success: Bool, _ commentIdentifier: String, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let undimCommentSuccessfulStatusCode = 204
    
    return signedAPIRequest(target: .undimComment(identifier: commentIdentifier), completion: {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        var success: Bool = false
        var commentIdentifier = commentIdentifier
        var error: BookwittyAPIError? = error
        defer {
          DispatchQueue.main.async {
            completion(success, commentIdentifier, error)
          }
        }
        
        guard statusCode == undimCommentSuccessfulStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }
        
        success  = true
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
