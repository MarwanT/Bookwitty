//
//  CommentsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class CommentsViewModel {
  fileprivate(set) var commentsManager: CommentsManager?
  fileprivate(set) var parentCommentIdentifier: String?
  
  fileprivate(set) var commentsIDs = [String]()
  
  fileprivate var cancellableRequest: Cancellable?
  
  var displayMode: CommentsNode.DisplayMode = .normal
  
  var isFetchingData: Bool = false
  
  var postId: String? {
    return commentsManager?.postIdentifier
  }
  
  func initialize(with resource: ModelCommonProperties, parentCommentIdentifier: String?) {
    self.commentsManager = CommentsManager.manager(resource: resource)
    self.parentCommentIdentifier = parentCommentIdentifier
  }
  
  var numberOfSection: Int {
    return CommentsNode.Section.numberOfSections
  }
  
  func refreshData() {
    commentsIDs = commentsManager?.commentsIDs(parentCommentIdentifier: parentCommentIdentifier) ?? []
  }
  
  func dataChanges(relativeToCommentWith identifier: String, commentParentIdentifier: String?) -> CommentsListingUpdateType? {
    let newCommentsIDs = commentsManager?.commentsIDs(parentCommentIdentifier: parentCommentIdentifier) ?? []
    
    let isInNewIdentifiersArray = newCommentsIDs.contains(identifier)
    let isInOldIdentifiersArray = commentsIDs.contains(identifier)
    
    if !isInOldIdentifiersArray && isInNewIdentifiersArray {
      let index = newCommentsIDs.index(of: identifier)!
      return .addComment(index: index)
    } else if isInOldIdentifiersArray && !isInNewIdentifiersArray {
      let index = commentsIDs.index(of: identifier)!
      return .removeComment(index: index)
    } else if !isInOldIdentifiersArray && !isInNewIdentifiersArray {
      guard let commentParentIdentifier = commentParentIdentifier else {
        return nil
      }
      let index = commentsIDs.index(of: commentParentIdentifier)!
      return .updateTree(index: index)
    }
    
    return nil
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
      var itemsNumber = commentsIDs.count
      if case displayMode = CommentsNode.DisplayMode.compact {
        itemsNumber = min(itemsNumber, CommentsNode.DisplayMode.maximumCompactLines)
      }
      return itemsNumber
    case CommentsNode.Section.viewAllComments.rawValue:
      let isCompactMode = displayMode == CommentsNode.DisplayMode.compact
      return (isCompactMode && !isFetchingData) ? 1 : 0
    default:
      return 0
    }
  }
  
  var hasNextPage: Bool {
    return commentsManager?.hasNextPage(commentIdentifier: parentCommentIdentifier) ?? false
  }
  
  var isDisplayingACommentReplies: Bool {
    return parentCommentIdentifier != nil
  }
}

// MARK: - NETWORK
extension CommentsViewModel {
  func load(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    if let parentCommentIdentifier = parentCommentIdentifier {
      loadReplies(for: parentCommentIdentifier, completion: completion)
    } else {
      loadComments(completion: completion)
    }
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    if let parentCommentIdentifier = parentCommentIdentifier {
      loadMoreReplies(for: parentCommentIdentifier, completion: completion)
    } else {
      loadMoreComments(completion: completion)
    }
  }
  
  private func loadComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, CommentsManager.Error.managerConfiguration)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = commentsManager.loadComments(completion: {
      (success, error) in
      self.isFetchingData = false
      self.cancellableRequest = nil
      if success {
        self.refreshData()
      }
      completion(success, error)
    })
  }
  
  private func loadReplies(for parentCommentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, CommentsManager.Error.managerConfiguration)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = commentsManager.loadReplies(for: parentCommentIdentifier, completion: {
      (success, error) in
      self.isFetchingData = false
      self.cancellableRequest = nil
      if success {
        self.refreshData()
      }
      completion(success, error)
    })
  }
  
  private func loadMoreComments(completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, CommentsManager.Error.managerConfiguration)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = commentsManager.loadMoreComments(completion: {
      (success, error) in
      self.isFetchingData = false
      self.cancellableRequest = nil
      if success {
        self.refreshData()
      }
      completion(success, error)
    })
  }
  
  private func loadMoreReplies(for parentCommentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, CommentsManager.Error.managerConfiguration)
      return
    }
    
    isFetchingData = true
    cancellableRequest?.cancel()
    cancellableRequest = commentsManager.loadMoreReplies(for: parentCommentIdentifier, completion: {
      (success, error) in
      self.isFetchingData = false
      self.cancellableRequest = nil
      if success {
        self.refreshData()
      }
      completion(success, error)
    })
  }
}

// MARK: - Utilities
extension CommentsViewModel {
  func commentInfo(for indexPath: IndexPath) -> CommentInfo? {
    guard let section = CommentsNode.Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .parentComment:
      // The parent ID is unraped here because it is basically impossible
      // To reach this code if the parent ID is nil
      let comment = commentsManager?.comment(with: parentCommentIdentifier!)
      return comment?.info()
    case .read:
      fallthrough
    default:
      let commentIdentifier = commentsIDs[indexPath.item]
      return commentsManager?.comment(with: commentIdentifier)?.info()
    }
  }
  
  func commentInfo(forCommentWithIdentifier id: String) -> CommentInfo? {
    return commentsManager?.comment(with: id)?.info()
  }
  
  func repliesInfo(forParentCommentIdentifier identifier: String) -> [CommentInfo] {
    return commentsManager?.replies(forParentCommentIdentifier: identifier).flatMap({ $0.info() }) ?? []
  }
  
  func parentIdentifier(for commentIdentifier: String) -> String? {
    return commentsManager?.comment(with: commentIdentifier)?.parentId
  }
  
  func parentIdentifier(forCommentWithIdentifier identifier: String, action: CardActionBarNode.Action) -> String? {
    switch action {
    case .reply:
      return identifier
    default:
      return commentsManager?.comment(with: identifier)?.parentId
    }
  }
  
  var displayedTotalNumberOfComments: String {
    return "\(totalNumberOfComments ?? 0)" + " " + Strings.comments().lowercased()
  }
  
  var totalNumberOfComments: Int? {
    if isDisplayingACommentReplies {
      guard let parentCommentIdentifier = parentCommentIdentifier,
        let comment = commentsManager?.comment(with: parentCommentIdentifier) else {
        return nil
      }
      return comment.counts?.children
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
  func publishComment(content: String?, parentCommentIdentifier: String?, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.publishComment(content: content, parentCommentIdentifier: parentCommentIdentifier, completion: {
      (success, comment, error) in
      completion(success, error)
    })
  }
  
  func removeComment(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.removeComment(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func wit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.wit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func unwit(commentIdentifier: String, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil)
      return
    }
    
    commentsManager.unwit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion(success, error)
    }
  }
}
