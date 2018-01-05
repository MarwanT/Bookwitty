//
//  CommentRegistryItem.swift
//  Bookwitty
//
//  Created by Marwan  on 12/19/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CommentRegistryItem {
  var comment: Comment?
  var pageURL: URL?
  var nextPageURL: URL?
  
  /**
   This flag is updated in the comments manager. When the first page of a
   comment is loaded this flag is set tot true to prevent another
   fetch if that same comment comments were requested
   */
  var isLoaded: Bool = false
  
  var commentIdentifier: String? {
    return comment?.id
  }
  var parentCommentIdentifier: String? {
    return comment?.parentId
  }
  
  init(_ comment: Comment? = nil) {
    self.comment = comment
  }
  
  func isRegistry(for commentIdentifier: String?) -> Bool {
    guard let registryId = self.commentIdentifier, let commentIdentifier = commentIdentifier else {
      return false
    }
    return registryId == commentIdentifier
  }
  
  func isRegistry(for comment: Comment) -> Bool {
    guard let registryId = self.commentIdentifier, let commentIdentifier = comment.id else {
      return false
    }
    return registryId == commentIdentifier
  }
  
  /// This method flattens all the comments into one dimentional registry items array
  static func generateRegistry(from comments: [Comment]) -> [CommentRegistryItem] {
    var registry = [CommentRegistryItem]()
    comments.forEach { (comment) in
      registry.append(CommentRegistryItem(comment))
      if let commentReplies = comment.replies, commentReplies.count > 0 {
        registry.append(contentsOf: generateRegistry(from: commentReplies))
      }
    }
    return registry
  }
}
