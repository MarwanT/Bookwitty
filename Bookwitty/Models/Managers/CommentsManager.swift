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
  
  func updateData(with updatedComment: Comment) {
    guard let index = comments.index(where: { $0.id == updatedComment.id }) else {
      return
    }
    comments.remove(at: index)
    comments.insert(updatedComment, at: index)
  }
  
  var hasNextPage: Bool {
    return nextPageURL != nil
  }
  
  func clone() -> CommentManager? {
    guard let postIdentifier = postIdentifier else {
      return nil
    }
    
    var manager = CommentManager()
    manager.initialize(postIdentifier: postIdentifier, commentIdentifier: commentIdentifier, comments: comments, nextPageURL: nextPageURL)
    return manager
  }
  
  func comment(for identifier: String) -> Comment? {
    return comments.filter({ $0.id == identifier }).first
  }
}

// MARK: Network Calls
extension CommentManager {
  func loadComments(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard postIdentifier != nil else {
      completion(false, CommentManager.Error.missingPostId)
      return
    }
    
    if commentIdentifier == nil {
      loadCommentsForPost(completion: completion)
    } else {
      loadCommentReplies(completion: completion)
    }
  }
  
  private func loadCommentsForPost(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard !isFetchingData, let postIdentifier = postIdentifier else {
      completion(false, CommentManager.Error.missingPostId)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.comments(postIdentifier: postIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentManager.Error.api(error))
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  private func loadCommentReplies(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard !isFetchingData, let commentIdentifier = commentIdentifier else {
      completion(false, CommentManager.Error.unidentified)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.commentReplies(identifier: commentIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentManager.Error.api(error))
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard !isFetchingData, let url = nextPageURL else {
      completion(false, CommentManager.Error.unidentified)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, url, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentManager.Error.api(error))
      }
      
      guard success, let comments = resources as? [Comment] else {
        return
      }
      self.comments.append(contentsOf: comments)
      self.nextPageURL = url
    })
  }
  
  func publishComment(content: String?, parentCommentId: String?, completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentManager.Error.missingPostId)
      return
    }
    
    guard let content = content, !content.isBlank else {
      completion(false, CommentManager.Error.publishEmptyComment)
      return
    }
    
    _ = CommentAPI.createComment(postIdentifier: postIdentifier, commentMessage: content, parentCommentIdentifier: parentCommentId, completion: {
      (success, comment, error) in
      defer {
        completion(success, CommentManager.Error.api(error))
      }
      
      guard success else {
        return
      }
      
      // Do additional logic here if necessary
      NotificationCenter.default.post(
        name: CommentManager.notificationName(for: postIdentifier),
        object: (CommentsNode.Action.writeComment(parentCommentIdentifier: nil, postId: postIdentifier), comment))
    })
  }
}

// MARK: - Comments related errors
extension CommentManager {
  enum Error {
    case publishEmptyComment
    case api(BookwittyAPIError?)
    case missingPostId
    case unidentified
    
    var title: String? {
      switch self {
      case .publishEmptyComment:
        return "No Valid"
      case .api, .missingPostId, .unidentified:
        return "Ooops something went wrong"
      }
    }
    
    var message: String? {
      switch self {
      case .publishEmptyComment:
        return "Your Comment Is Empty cannot publish it"
      case .api, .missingPostId, .unidentified:
        return "Something went wrong"
      }
    }
  }
}

// MARK: - Notifications related
extension CommentManager {
  typealias CommentNotificationObject = (action: CommentsNode.Action, comment: Comment)
  class func notificationName(for identifier: String) -> Notification.Name {
    return Notification.Name("comments-updates-for-id:\(identifier)") 
  }
}
