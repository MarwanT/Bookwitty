//
//  CommentsManager.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class CommentManager {
  private(set) var postIdentifier: String?
  private(set) var commentIdentifier: String?
  
  fileprivate var comments = [Comment]()
  fileprivate var nextPageURL: URL?
  
  fileprivate var cancellableRequest: Cancellable?
  
  var isFetchingData = false
  
  /// The loaded comments are replies for the comment with the provided id
  /// if available, otherwise the comments are the post main comments
  func initialize(postIdentifier: String, commentIdentifier: String? = nil, comments: [Comment]? = nil, nextPageURL: URL? = nil) {
    self.postIdentifier = postIdentifier
    self.commentIdentifier = commentIdentifier
    if let comments = comments {
      self.comments = comments
    }
    self.nextPageURL = nextPageURL
  }
  
  var numberOfComments: Int {
    return comments.count
  }
  
  func comment(at index: Int) -> Comment? {
    return comments[index]
  }
  
  var hasNextPage: Bool {
    return nextPageURL != nil
  }
}

// MARK: Network Calls
extension CommentManager {
  func loadComments(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    if postIdentifier != nil {
      loadCommentsForPost(completion: completion)
    } else if commentIdentifier != nil {
      loadCommentReplies(completion: completion)
    }
  }
  
  private func loadCommentsForPost(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard !isFetchingData, let postIdentifier = postIdentifier else {
      completion(false, BookwittyAPIError.undefined)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.comments(postIdentifier: postIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, error)
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  private func loadCommentReplies(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard !isFetchingData, let commentIdentifier = commentIdentifier else {
      completion(false, BookwittyAPIError.undefined)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.commentReplies(identifier: commentIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, error)
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard !isFetchingData, let url = nextPageURL else {
      completion(false, BookwittyAPIError.undefined)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, url, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, error)
      }
      
      guard success, let comments = resources as? [Comment] else {
        return
      }
      self.comments.append(contentsOf: comments)
      self.nextPageURL = url
    })
  }
}
