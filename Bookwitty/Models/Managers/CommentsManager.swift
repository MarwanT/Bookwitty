//
//  CommentsManager.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class CommentManager {
  private(set) var postIdentifier: String?
  private(set) var commentIdentifier: String?
  
  fileprivate var comments = [Comment]()
  fileprivate var nextPageURL: URL?
  
  fileprivate var cancellableRequest: Cancellable?
  
  var isFetchingData = false
  
  func initialize(postIdentifier: String) {
    self.postIdentifier = postIdentifier
    self.commentIdentifier = nil
  }
  
  func initialize(commentIdentifier: String) {
    self.postIdentifier = nil
    self.commentIdentifier = commentIdentifier
  }
}
