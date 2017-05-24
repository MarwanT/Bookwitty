//
//  Comment.swift
//  Bookwitty
//
//  Created by Marwan  on 5/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Comment: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var body: String?
  var parentId: String?
  var penName: PenName?
  var counts: Counts?
  var vote: String?
  
}
