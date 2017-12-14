//
//  CommentsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CommentsViewModel {
  fileprivate(set) var commentsManager: CommentsManager?
  
  var parentComment: Comment? {
    return commentsManager?.parentComment
  }
  
  var displayMode: CommentsNode.DisplayMode = .normal
  
  var postId: String? {
    return commentsManager?.postIdentifier
  }
  
  func initialize(with resource: ModelCommonProperties, parentComment: Comment?) {
    // TODO: Change when centralizing the comments data
    let newManager = CommentsManager()
    newManager.initialize(resource: resource, parentComment: parentComment)
    commentsManager = newManager
  }
  
  var numberOfSection: Int {
    return CommentsNode.Section.numberOfSections
  }
  
  func numberOfItems(in section: Int) -> Int {
    switch section {
    case CommentsNode.Section.count.rawValue:
      return displayMode == .compact ? 0 : 1
    case CommentsNode.Section.parentComment.rawValue:
      return isDisplayingACommentReplies ? 1 : 0
    case CommentsNode.Section.header.rawValue:
      return displayMode == .compact ? 1 : 0
    case CommentsNode.Section.write.rawValue:
      return displayMode == .compact ? 1 : 0
    case CommentsNode.Section.read.rawValue:
      var itemsNumber = commentsManager?.numberOfComments ?? 0
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
  
  func loadComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    commentsManager?.loadComments(completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    commentsManager?.loadMore(completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  var isFetchingData: Bool {
    return commentsManager?.isFetchingData ?? false
  }
  
  var hasNextPage: Bool {
    return commentsManager?.hasNextPage ?? false
  }
  
  var isDisplayingACommentReplies: Bool {
    return commentsManager?.parentComment != nil
  }
}

// MARK: Utilities
extension CommentsViewModel {
  func updateData(with updatedComment: Comment) {
    commentsManager?.updateData(with: updatedComment)
  }
  
  func comment(for indexPath: IndexPath) -> Comment? {
    switch indexPath.section {
    case CommentsNode.Section.parentComment.rawValue:
      return commentsManager?.parentComment
    case CommentsNode.Section.read.rawValue:
      fallthrough
    default:
      return commentsManager?.comment(at: indexPath.item)
    }
  }
  
  /// If the comments displayed are replies of a certain comment then the
  /// value of this property will be that parent comment id. Otherwise nil
  var parentCommentIdentifier: String? {
    return commentsManager?.parentComment?.id
  }
  
  var displayedTotalNumberOfComments: String {
    return "\(totalNumberOfComments ?? 0)" + " " + Strings.comments().lowercased()
  }
  
  var totalNumberOfComments: Int? {
    if isDisplayingACommentReplies {
      return commentsManager?.parentComment?.counts?.children
    } else {
      return resource?.counts?.comments
    }
  }
  
  var resource: ModelCommonProperties? {
    return commentsManager?.resource
  }
  
  var resourceExcerpt: String? {
    return commentsManager?.resourceExcerpt
  }
}

// MARK: - Related methods
extension CommentsViewModel {
  func publishComment(content: String?, parentComment: Comment?, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.publishComment(content: content, parentComment: parentComment, completion: {
      (success, comment, error) in
      completion(success, error)
    })
  }
  
  func wit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.wit(comment: comment) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func unwit(comment: Comment, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.unwit(comment: comment) {
      (success, error) in
      completion(success, error)
    }
  }
}
