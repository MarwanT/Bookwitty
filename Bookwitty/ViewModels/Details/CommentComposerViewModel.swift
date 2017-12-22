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
  fileprivate(set) var parentCommentIdentifier: String?
  
  func initialize(with resource: ModelCommonProperties, parentCommentIdentifier: String?) {
    self.commentsManager = CommentsManager.manager(resource: resource)
    self.parentCommentIdentifier = parentCommentIdentifier
  }
  
  var resource: ModelCommonProperties? {
    return commentsManager?.resource
  }
  
  var resourceExcerpt: String? {
    return commentsManager?.resourceExcerpt
  }
  
  var resourceTitlePresenterText: String {
    return Strings.in_response_to()
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
    
    commentsManager.publishComment(content: text, parentCommentIdentifier: parentCommentIdentifier) {
      (success, comment, error) in
      completion(success, comment, error)
    }
  }
}
