//
//  CommentAPI.swift
//  Bookwitty
//
//  Created by Marwan  on 5/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct CommentAPI {
  
}

extension CommentAPI {
  static func createCommentBody(comment: String, parentCommentIdentifier: String?) -> [String : Any]? {
    var attributes = ["body" : comment]
    if let parentCommentIdentifier = parentCommentIdentifier {
      attributes["parent-id"] = parentCommentIdentifier
    }
    
    let dictionary = [
      "data" : [
        "attributes" : attributes
      ]
    ]
    return dictionary
  }
}
