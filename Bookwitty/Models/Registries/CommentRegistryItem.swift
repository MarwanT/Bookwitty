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
}
