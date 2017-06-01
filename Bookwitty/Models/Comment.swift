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
  
  override class var resourceType: ResourceType {
    return "comments"
  }
  
  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt" : DateAttribute().serializeAs("created-at"),
      "updatedAt" : DateAttribute().serializeAs("updated-at"),
      "body" : Attribute().serializeAs("body"),
      "vote": Attribute().serializeAs("vote"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

extension Comment: Parsable {
  typealias AbstractType = Comment
}
