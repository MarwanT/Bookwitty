//
//  CommentComposerViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 11/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class CommentComposerViewModel {
  fileprivate(set) var commentsManager: CommentsManager?
  
  func initialize(with commentsManager: CommentsManager) {
    self.commentsManager = commentsManager
  }
  
  var resource: ModelCommonProperties? {
    return commentsManager?.resource
  }
  
  var resourceExcerpt: String? {
    return commentsManager?.resourceExcerpt
  }
  
  var resourceTitlePresenterText: String {
    return "In Response To"
  }
  
  var penNameImageURL: URL? {
    guard let stringURL = UserManager.shared.defaultPenName?.avatarUrl,
      let url = URL(string: stringURL) else {
        return nil
    }
    return url
  }
  
  func publishComment(text: String, completion: @escaping (_ success: Bool, _ comment: Comment?, _ error: CommentsManager.Error?) -> Void) {
    guard let commentsManager = commentsManager else {
      completion(false, nil, nil)
      return
    }
    
    commentsManager.publishComment(content: text, parentCommentId: commentsManager.parentComment?.id) {
      (success, comment, error) in
      completion(success, comment, error)
    }
  }
}
