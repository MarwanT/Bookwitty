//
//  CommentsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CommentsViewModel {
  fileprivate var commentManager: CommentManager?
  
  var displayMode: CommentsNode.DisplayMode = .normal
  
  var postId: String? {
    return commentManager?.postIdentifier
  }
  
  func initialize(with manager: CommentManager) {
    commentManager = manager
  }
  
  var numberOfSection: Int {
    return CommentsNode.Section.numberOfSections
  }
  
  func numberOfItems(in section: Int) -> Int {
    switch section {
    case CommentsNode.Section.header.rawValue:
      return 1
    case CommentsNode.Section.write.rawValue:
      return 1
    case CommentsNode.Section.read.rawValue:
      var itemsNumber = commentManager?.numberOfComments ?? 0
      if case displayMode = CommentsNode.DisplayMode.compact {
        itemsNumber = min(itemsNumber, 1)
      }
      return itemsNumber
    case CommentsNode.Section.viewAllComments.rawValue:
      let isCompactMode = displayMode == CommentsNode.DisplayMode.compact
      return (isCompactMode && !isFetchingData) ? 1 : 0
    default:
      return 0
    }
  }
  
  func loadComments(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    commentManager?.loadComments(completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    commentManager?.loadMore(completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  var isFetchingData: Bool {
    return commentManager?.isFetchingData ?? false
  }
  
  var hasNextPage: Bool {
    return commentManager?.hasNextPage ?? false
  }
}

// MARK: Utilities
extension CommentsViewModel {
  func updateData(with updatedComment: Comment) {
    commentManager?.updateData(with: updatedComment)
  }
  
  func comment(for indexPath: IndexPath) -> Comment? {
    return commentManager?.comment(at: indexPath.item)
  }
  
  /// Sends a clone of the comment manager held in this instance
  func commentManagerClone() -> CommentManager? {
    return commentManager?.clone()
  }
}

// MARK: - Related methods
extension CommentsViewModel {
  func publishComment(content: String?, parentCommentId: String?, completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard let commentManager = commentManager else {
      completion(false, nil)
      return
    }
    
    commentManager.publishComment(content: content, parentCommentId: parentCommentId, completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  func wit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard let commentManager = commentManager else {
      completion(false, nil)
      return
    }
    
    commentManager.wit(comment: comment) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func unwit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    guard let commentManager = commentManager else {
      completion(false, nil)
      return
    }
    
    commentManager.unwit(comment: comment) {
      (success, error) in
      completion(success, error)
    }
  }
  
  /// If the comments displayed are replies of a certain comment then the
  /// value of this property will be that parent comment id. Otherwise nil
  var parentCommentIdentifier: String? {
    return commentManager?.commentIdentifier
  }
}
