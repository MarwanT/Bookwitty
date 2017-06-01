//
//  CommentsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CommentsViewModel {
  var commentManager: CommentManager?
  
  func initialize(with manager: CommentManager) {
    commentManager = manager
  }
}
