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
  
  func comment(for indexPath: IndexPath) -> Comment? {
    return commentManager?.comment(at: indexPath.item)
  }
  
  func loadComments(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    commentManager?.loadComments(completion: {
      (success, error) in
      completion(success, error)
    })
  }
  
  func loadMore(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
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
