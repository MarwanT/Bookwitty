//
//  CommentsManager.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class CommentsManager {
  private(set) var postIdentifier: String?
  private(set) var parentComment: Comment?
  
  fileprivate var comments = [Comment]()
  fileprivate var nextPageURL: URL?
  
  fileprivate var cancellableRequest: Cancellable?
  
  var isFetchingData = false
  
  /// The loaded comments are replies for the comment provided
  /// if available, otherwise the comments are the post main comments
  func initialize(postIdentifier: String, comment: Comment? = nil, comments: [Comment]? = nil, nextPageURL: URL? = nil) {
    self.postIdentifier = postIdentifier
    self.parentComment = comment
    if let comments = comments {
      self.comments = comments
    }
    self.nextPageURL = nextPageURL
  }
  
  var numberOfComments: Int {
    return comments.count
  }
  
  func comment(at index: Int) -> Comment? {
    guard index < comments.count else {
      return nil
    }
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
  
  func clone() -> CommentsManager? {
    guard let postIdentifier = postIdentifier else {
      return nil
    }
    
    var manager = CommentsManager()
    manager.initialize(postIdentifier: postIdentifier, comment: parentComment, comments: comments, nextPageURL: nextPageURL)
    return manager
  }
  
  func comment(for identifier: String) -> Comment? {
    return comments.filter({ $0.id == identifier }).first
  }
}

// MARK: Network Calls
extension CommentsManager {
  func loadComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard postIdentifier != nil else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    if parentComment == nil {
      loadCommentsForPost(completion: completion)
    } else {
      loadCommentReplies(completion: completion)
    }
  }
  
  private func loadCommentsForPost(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard !isFetchingData, let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.comments(postIdentifier: postIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentsManager.Error.api(error))
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  private func loadCommentReplies(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard !isFetchingData, let commentIdentifier = parentComment?.id else {
      completion(false, CommentsManager.Error.unidentified)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = CommentAPI.commentReplies(identifier: commentIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentsManager.Error.api(error))
      }
      
      self.comments.removeAll()
      if let comments = comments {
        self.comments.append(contentsOf: comments)
      }
      
      self.nextPageURL = next
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard !isFetchingData, let url = nextPageURL else {
      completion(false, CommentsManager.Error.unidentified)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, url, error) in
      defer {
        self.isFetchingData = false
        self.cancellableRequest = nil
        completion(success, CommentsManager.Error.api(error))
      }
      
      guard success, let comments = resources as? [Comment] else {
        return
      }
      self.comments.append(contentsOf: comments)
      self.nextPageURL = url
    })
  }
  
  func publishComment(content: String?, parentCommentId: String?, completion: @escaping (_ success: Bool, _ comment: Comment?, _ error: CommentsManager.Error?) -> Void) {
    guard let postIdentifier = postIdentifier else {
      completion(false, nil, CommentsManager.Error.missingPostId)
      return
    }
    
    guard let content = content, !content.isBlank else {
      completion(false, nil, CommentsManager.Error.publishEmptyComment)
      return
    }
    
    _ = CommentAPI.createComment(postIdentifier: postIdentifier, commentMessage: content, parentCommentIdentifier: parentCommentId, completion: {
      (success, comment, error) in
      defer {
        completion(success, comment, CommentsManager.Error.api(error))
      }
      
      guard success else {
        return
      }
      
      // Do additional logic here if necessary
      NotificationCenter.default.post(
        name: CommentsManager.notificationName(for: postIdentifier),
        object: (CommentsNode.Action.writeComment(parentCommentIdentifier: nil, postId: postIdentifier), comment))
    })
  }
  
  func wit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    guard let commentId = comment.id else {
      completion(false, CommentsManager.Error.unidentified)
      return
    }
    
    _ = CommentAPI.wit(commentIdentifier: commentId, completion: {
      (success, commentId, error) in
      var responseError: CommentsManager.Error? = CommentsManager.Error.api(error)
      defer {
        completion(success, responseError)
      }
      
      guard success else {
        return
      }
      
      // Do additional logic here if necessary
      guard let comment = self.comment(for: commentId) else {
        responseError = CommentsManager.Error.unidentified
        return
      }
      
      self.wit(comment)
      NotificationCenter.default.post(
        name: CommentsManager.notificationName(for: postIdentifier),
        object: (CommentsNode.Action.commentAction(comment: comment, action: CardActionBarNode.Action.wit), comment))
    })
  }
  
  func unwit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    guard let commentId = comment.id else {
      completion(false, CommentsManager.Error.unidentified)
      return
    }
    
    _ = CommentAPI.unwit(commentIdentifier: commentId, completion: {
      (success, commentId, error) in
      var responseError: CommentsManager.Error? = CommentsManager.Error.api(error)
      defer {
        completion(success, responseError)
      }
      
      guard success else {
        return
      }
      
      // Do additional logic here if necessary
      guard let comment = self.comment(for: commentId) else {
        responseError = CommentsManager.Error.unidentified
        return
      }
      
      self.unwit(comment)
      NotificationCenter.default.post(
        name: CommentsManager.notificationName(for: postIdentifier),
        object: (CommentsNode.Action.commentAction(comment: comment, action: CardActionBarNode.Action.unwit), comment))
    })
  }
}

//MARK: - Update After Action Implementations
extension CommentsManager {
  fileprivate func wit(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.wit = true
  }
  
  fileprivate func unwit(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.wit = false
  }
  
  fileprivate func follow(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.isFollowing = true
  }
  
  fileprivate func unfollow(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.isFollowing = false
  }
}

// MARK: - Comments related errors
extension CommentsManager {
  enum Error {
    case publishEmptyComment
    case api(BookwittyAPIError?)
    case missingPostId
    case unidentified
    
    var title: String? {
      switch self {
      case .publishEmptyComment:
        return Strings.publishEmptyCommentErrorTitle()
      case .api, .missingPostId, .unidentified:
        return Strings.publishCommentGeneralErrorTitle()
      }
    }
    
    var message: String? {
      switch self {
      case .publishEmptyComment:
        return Strings.publishEmptyCommentErrorMessage()
      case .api, .missingPostId, .unidentified:
        return Strings.publishCommentGeneralErrorMessage()
      }
    }
  }
}

// MARK: - Notifications related
extension CommentsManager {
  typealias CommentNotificationObject = (action: CommentsNode.Action, comment: Comment)
  class func notificationName(for identifier: String) -> Notification.Name {
    return Notification.Name("comments-updates-for-id:\(identifier)") 
  }
}
