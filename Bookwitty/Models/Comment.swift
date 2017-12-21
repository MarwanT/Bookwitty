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
  
  @objc
  private var repliesCollection: LinkedResourceCollection?
  lazy var replies: [Comment]? = {
    guard let replyComments = self.repliesCollection?.resources as? [Comment] else {
      return nil
    }
    replyComments.forEach({
      $0.parentId = self.id
    })
    return replyComments
  }()
  
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
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "repliesCollection" : ToManyRelationship(Comment.self).serializeAs("children")
      ])
  }
}

extension Comment: Parsable {
  typealias AbstractType = Comment
}
