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
  fileprivate static var managersPool = NSPointerArray.weakObjects()
  
  private(set) var resource: ModelCommonProperties?
  
  fileprivate var commentsRegistry = [CommentRegistryItem]()
  fileprivate var nextPageURL: URL?
  fileprivate var isLoaded: Bool = false
  
  fileprivate init() {}
  
  fileprivate func initialize(resource: ModelCommonProperties?) {
    self.resource = resource
  }
  
  var resourceExcerpt: String? {
    return resource?.title ?? resource?.shortDescription
  }
  
  var postIdentifier: String? {
    return resource?.id
  }
  
  var totalNumberOfComments: Int {
    return resource?.counts?.comments ?? 0
  }
  
  var totalNumberOfCommentors: Int {
    return resource?.counts?.commenters ?? 0
  }
}

// MARK: - APIS
extension CommentsManager {
  func numberOfComments(parentCommentIdentifier: String? = nil) -> Int {
    return commentsIDs(parentCommentIdentifier: parentCommentIdentifier).count
  }
  
  func commentsIDs(parentCommentIdentifier: String? = nil) -> [String] {
    return commentsRegistry.filter({ $0.parentCommentIdentifier == parentCommentIdentifier }).flatMap({ $0.commentIdentifier })
  }
  
  func comment(with commentIdentifier: String) -> Comment? {
    return commentsRegistry.first(where: { $0.commentIdentifier == commentIdentifier })?.comment
  }
  
  func replies(forParentCommentIdentifier identifier: String) -> [Comment] {
    return commentsRegistry.filter({ $0.parentCommentIdentifier == identifier }).flatMap({ $0.comment })
  }
  
  func hasNextPage(commentIdentifier: String?) -> Bool {
    if let commentIdentifier = commentIdentifier {
      guard let registry = commentsRegistry.first(where: { $0.commentIdentifier == commentIdentifier }) else {
        return false
      }
      return registry.nextPageURL != nil
    } else {
      return nextPageURL != nil
    }
  }
}

// MARK: - REGISTRY GETTERS
extension CommentsManager {
  fileprivate func commentRegistryItem(for comment: Comment) -> CommentRegistryItem? {
    guard let index = commentsRegistry.index(where: { $0.isRegistry(for: comment) }) else {
      return nil
    }
    return commentsRegistry[index]
  }
  
  fileprivate func commentRegistryItem(for commentIdentifier: String) -> CommentRegistryItem? {
    guard let index = commentsRegistry.index(where: { $0.isRegistry(for: commentIdentifier) }) else {
      return nil
    }
    return commentsRegistry[index]
  }
}

// MARK: - REGISTRY MODIFIERS
extension CommentsManager {
  fileprivate func clearRegistry() {
    commentsRegistry.removeAll()
  }
  
  /// If there is no registry for a comment in the array, then a new one is created
  /// Otherwise the already present registry is Updated
  fileprivate func updateRegistry(with comments: [Comment], pageURL: URL? = nil, ignoreNilPageURLS: Bool = true) {
    comments.forEach { comment in
      _ = updateRegistry(with: comment, pageURL: pageURL, ignoreNilPageURLS: ignoreNilPageURLS)
    }
  }
  
  /// If there is no registry for a comment in the array, then a new one is created
  /// Otherwise the already present registry is Updated
  fileprivate func updateRegistry(with comment: Comment, addFromBeginning: Bool = false, pageURL: URL? = nil, ignoreNilPageURLS: Bool = true) -> CommentRegistryItem? {
    let updatedRegistry: CommentRegistryItem?
    if let commentRegistryItem = commentRegistryItem(for: comment) {
      commentRegistryItem.comment = comment
      if !ignoreNilPageURLS {
        commentRegistryItem.pageURL = pageURL
      } else if let pageURL = pageURL {
        commentRegistryItem.pageURL = pageURL
      }
      updatedRegistry = commentRegistryItem
    } else {
      let commentRegistry = CommentRegistryItem.generateRegistry(from: [comment])
      if !ignoreNilPageURLS {
        commentRegistry.forEach({ $0.pageURL = pageURL })
      } else if let pageURL = pageURL {
        commentRegistry.forEach({ $0.pageURL = pageURL })
      }
      
      if addFromBeginning {
        /**
         If the added comment is a main comment then add it at the beginning
         of the registry.
         */
        commentsRegistry.insert(contentsOf: commentRegistry, at: 0)
      } else {
        commentsRegistry.append(contentsOf: commentRegistry)
      }
      updatedRegistry = commentRegistryItem(for: comment)
    }
    return updatedRegistry
  }
  
  private func removeRegistry(for commentIdentifier: String) {
    guard let index = commentsRegistry.index(where: { $0.commentIdentifier == commentIdentifier }) else {
      return
    }
    commentsRegistry.remove(at: index)
  }
  
  fileprivate func removeRegistry(for commentIdentifiers: [String], removeReplies: Bool = true) {
    commentIdentifiers.forEach({ commentIdentifier in
      if removeReplies {
        let repliesIDs = commentsRegistry.filter({ $0.parentCommentIdentifier == commentIdentifier }).flatMap({ $0.commentIdentifier })
        if repliesIDs.count > 0 {
          removeRegistry(for: repliesIDs, removeReplies: removeReplies)
        }
      }
      removeRegistry(for: commentIdentifier)
    })
  }
  
  fileprivate func witComment(with commentIdentifier: String) {
    guard let resource = resource,
      let resourceIdentifier = resource.id,
      let registry = commentsRegistry.first(where: { $0.commentIdentifier == commentIdentifier }),
      let commentIdentifier = registry.commentIdentifier else {
      return
    }
    registry.comment?.wit = true
    
    NotificationCenter.default.post(
      name: CommentsManager.notificationName(for: resourceIdentifier),
      object: (
        action: CommentsNode.Action.commentAction(
          commentIdentifier: commentIdentifier,
          action: CardActionBarNode.Action.wit,
          resource: resource,
          parentCommentIdentifier: registry.parentCommentIdentifier),
        commentIdentifier: commentIdentifier
      )
    )
  }
  
  fileprivate func unwitComment(with commentIdentifier: String) {
    guard let resource = resource,
      let resourceIdentifier = resource.id,
      let registry = commentsRegistry.first(where: { $0.commentIdentifier == commentIdentifier }),
      let commentIdentifier = registry.commentIdentifier else {
        return
    }
    registry.comment?.wit = false
    
    NotificationCenter.default.post(
      name: CommentsManager.notificationName(for: resourceIdentifier),
      object: (
        action: CommentsNode.Action.commentAction(
          commentIdentifier: commentIdentifier,
          action: CardActionBarNode.Action.unwit,
          resource: resource,
          parentCommentIdentifier: registry.parentCommentIdentifier),
        commentIdentifier: commentIdentifier
      )
    )
  }
}

// MARK: - Network Calls
extension CommentsManager {
  func loadComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) -> Cancellable? {
    guard !isLoaded else {
      completion(true, nil)
      return nil
    }
    
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return nil
    }
    
    return CommentAPI.comments(postIdentifier: postIdentifier, completion: {
      (success, comments, next, error) in
      defer {
        completion(success, CommentsManager.Error.api(error))
      }
      
      self.isLoaded = success
      
      self.clearRegistry()
      if let comments = comments {
        self.updateRegistry(with: comments)
      }
  
      self.nextPageURL = next
    })
  }
  
  func loadReplies(for parentCommentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) -> Cancellable? {
    guard var registry = commentRegistryItem(for: parentCommentIdentifier) else {
      completion(false, CommentsManager.Error.unidentified)
      return nil
    }
    
    guard !registry.isLoaded else {
      completion(true, nil)
      return nil
    }
    
    return CommentAPI.commentReplies(identifier: parentCommentIdentifier, completion: {
      (success, comments, next, error) in
      var completionError: CommentsManager.Error?
      defer {
        completion(success, completionError ?? CommentsManager.Error.api(error))
      }
      
      // Set the loaded flag
      registry.isLoaded = success
      
      // Update the next URL for the comment
      registry.nextPageURL = next
      
      // Update the registry with the fetched comments
      if let comments = comments {
        self.updateRegistry(with: comments)
      }
      
      self.nextPageURL = next
    })
  }

  /*
   One Key Factor to take into consideration, before calling this method the
   `loadComments(completion:...)` method should be called
   */
  func loadMoreComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) -> Cancellable? {
    guard let url = nextPageURL else {
      completion(false, CommentsManager.Error.unidentified)
      return nil
    }
    
    return GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, url, error) in
      defer {
        completion(success, CommentsManager.Error.api(error))
      }
      
      guard success, let comments = resources as? [Comment] else {
        return
      }
      self.updateRegistry(with: comments, pageURL: url)
      self.nextPageURL = url
    })
  }
  
  /*
   One Key Factor to take into consideration, before calling this method the
   `loadReplie(for: Comment, completion:...)` method should be called
   */
  func loadMoreReplies(for parentCommentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) -> Cancellable? {
    guard let commentRegistry = commentRegistryItem(for: parentCommentIdentifier),
      let url = commentRegistry.nextPageURL else {
      completion(false, CommentsManager.Error.unidentified)
      return nil
    }
    
    return GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, url, error) in
      defer {
        completion(success, CommentsManager.Error.api(error))
      }
      
      guard success, let comments = resources as? [Comment] else {
        return
      }
      // Set the parent ID for fetched replies
      comments.forEach({ $0.parentId = parentCommentIdentifier })
      // Add the replies to the Registry
      self.updateRegistry(with: comments, pageURL: url)
      // Update the nextPageURL for the parent comment
      commentRegistry.nextPageURL = url
    })
  }
  
  func publishComment(content: String?, parentCommentIdentifier: String?, completion: @escaping (_ success: Bool, _ comment: Comment?, _ error: CommentsManager.Error?) -> Void) {
    guard let resource = resource else {
      completion(false, nil, CommentsManager.Error.missingResource)
      return
    }
    
    guard let postIdentifier = resource.id else {
      completion(false, nil, CommentsManager.Error.missingPostId)
      return
    }
    
    guard let content = content, !content.isBlank else {
      completion(false, nil, CommentsManager.Error.publishEmptyComment)
      return
    }
    
    _ = CommentAPI.createComment(postIdentifier: postIdentifier, commentMessage: content, parentCommentIdentifier: parentCommentIdentifier, completion: {
      (success, comment, error) in
      defer {
        completion(success, comment, CommentsManager.Error.api(error))
      }
      
      guard success, let comment = comment,
        let commentIdentifier = comment.id else {
        return
      }
      _ = self.updateRegistry(with: comment, addFromBeginning: true)
      
      // Update the Count
      self.increaseCountForAdded(comment: comment)
      
      // Send notification
      NotificationCenter.default.post(
        name: CommentsManager.notificationName(for: postIdentifier),
        object: (
          action: CommentsNode.Action.writeComment(
            resource: resource,
            parentCommentIdentifier: comment.parentId),
          commentIdentifier: commentIdentifier
        )
      )
    })
  }
  
  func removeComment(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let resource = self.resource else {
      completion(false, CommentsManager.Error.missingResource)
      return
    }
    
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    _ = CommentAPI.removeComment(commentIdentifier: commentIdentifier, completion: {
      (success, commentId, error) in
      var responseError: CommentsManager.Error? = CommentsManager.Error.api(error)
      defer {
        completion(success, responseError)
      }
      
      // Do additional logic here if necessary
      guard success, let comment = self.comment(with: commentIdentifier) else {
        return
      }
      
      // Update the Count
      self.decreaseCountForRemoved(comment: comment)
      
      // Remove the comment registry
      self.removeRegistry(for: [commentIdentifier])
      
      // Send notification
      NotificationCenter.default.post(
        name: CommentsManager.notificationName(for: postIdentifier),
        object: (
          action: CommentsNode.Action.commentAction(
            commentIdentifier: commentIdentifier, action: .remove,
            resource: resource, parentCommentIdentifier: comment.parentId),
          commentIdentifier: commentIdentifier))
    })
  }
  
  func wit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let resource = self.resource else {
      completion(false, CommentsManager.Error.missingResource)
      return
    }
    
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    _ = CommentAPI.wit(commentIdentifier: commentIdentifier, completion: {
      (success, commentId, error) in
      var responseError: CommentsManager.Error? = CommentsManager.Error.api(error)
      defer {
        completion(success, responseError)
      }
      
      guard success else {
        return
      }
      
      self.witComment(with: commentIdentifier)
    })
  }
  
  func unwit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let resource = self.resource else {
      completion(false, CommentsManager.Error.missingResource)
      return
    }
    
    guard let postIdentifier = postIdentifier else {
      completion(false, CommentsManager.Error.missingPostId)
      return
    }
    
    _ = CommentAPI.unwit(commentIdentifier: commentIdentifier, completion: {
      (success, commentId, error) in
      var responseError: CommentsManager.Error? = CommentsManager.Error.api(error)
      defer {
        completion(success, responseError)
      }
      
      guard success else {
        return
      }
      
      guard success else {
        return
      }
      
      self.unwitComment(with: commentIdentifier)
    })
  }
}

// MARK: - HELPERS
extension CommentsManager {
  fileprivate func increaseCountForAdded(comment: Comment) {
    resource?.counts?.comments = (resource?.counts?.comments ?? 0) + 1
    if let parentIdentifier = comment.parentId {
      guard let parentComment = self.comment(with: parentIdentifier) else {
        return
      }
      parentComment.counts?.children = (parentComment.counts?.children ?? 0) + 1
    }
  }
  
  fileprivate func decreaseCountForRemoved(comment: Comment) {
    resource?.counts?.comments = (resource?.counts?.comments ?? 1) - ((comment.counts?.children ?? 0) + 1)
    if let parentIdentifier = comment.parentId {
      guard let parentComment = self.comment(with: parentIdentifier) else {
        return
      }
      parentComment.counts?.children = (parentComment.counts?.children ?? 1) - ((comment.counts?.children ?? 0) + 1)
    }
  }
}

// MARK: - Comments related errors
extension CommentsManager {
  enum Error {
    case publishEmptyComment
    case api(BookwittyAPIError?)
    case missingPostId
    case unidentified
    case missingResource
    case isOccupied
    case managerConfiguration
    
    var title: String? {
      switch self {
      case .publishEmptyComment:
        return Strings.publish_empty_comment_error_title()
      case .api, .missingPostId, .unidentified, .missingResource, .isOccupied, .managerConfiguration:
        return Strings.publish_comment_general_error_title()
      }
    }
    
    var message: String? {
      switch self {
      case .publishEmptyComment:
        return Strings.publish_empty_comment_error_message()
      case .api, .missingPostId, .unidentified, .missingResource, .isOccupied, .managerConfiguration:
        return Strings.publish_comment_general_error_message()
      }
    }
  }
}

// MARK: - Notifications related
extension CommentsManager {
  typealias CommentNotificationObject = (action: CommentsNode.Action, commentIdentifier: String)
  class func notificationName(for identifier: String) -> Notification.Name {
    return Notification.Name("comments-updates-for-id:\(identifier)") 
  }
}

// MARK: - MANAGERS MANAGEMENT
                                    //****\\
extension CommentsManager {
  static func manager(resource: ModelCommonProperties) -> CommentsManager {
    // Clear the managers pool
    managersPool.compact()
    
    // Retrieve or create manager for the given resource
    guard let managers = managersPool.allObjects as? [CommentsManager],
      let manager =  managers.first(where: { $0.resource?.id == resource.id }) else {
        let newManager = CommentsManager()
        newManager.initialize(resource: resource)
        managersPool.addObject(newManager)
        return newManager
    }
    return manager
  }
}
