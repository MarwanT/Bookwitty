//
//  Topic.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Topic: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var shortDescription: String?
  var longDescription: String?
  var title: String?
  var penName: PenName?
  var vote: String?
  var counts: Counts?

  @objc
  private var reportedAsSpam: NSNumber?
  var isReported: Bool? {
    get {
      return ((reportedAsSpam?.intValue ?? 0) == 1)
    }
    set {
      reportedAsSpam = NSNumber(value: newValue ?? false)
    }
  }

  @objc
  private var topCommentsCollection: LinkedResourceCollection?
  lazy var topComments: [Comment]? = {
    return self.topCommentsCollection?.resources as? [Comment]
  }()

  @objc
  private var followingNumber: NSNumber?
  var following: Bool {
    get {
    return ((followingNumber?.intValue ?? 0) == 1)
    }
    set {
      followingNumber = NSNumber(value: newValue)
    }
  }

  @objc
  private var contributorsCollection: LinkedResourceCollection?
  lazy var contributors: [PenName]? = {
    return self.contributorsCollection?.resources as? [PenName]
  }()

  @objc
  fileprivate var countsDictionary: [String : Any]?
  
  override class var resourceType: ResourceType {
    return "topics"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "vote": Attribute().serializeAs("vote"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "longDescription": Attribute().serializeAs("description"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "title": Attribute().serializeAs("title"),
      "followingNumber": Attribute().serializeAs("following"),
      "reportedAsSpam": BooleanAttribute().serializeAs("reported-as-spam"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "contributorsCollection" : ToManyRelationship(PenName.self).serializeAs("contributors"),
      "topCommentsCollection" : ToManyRelationship(Comment.self).serializeAs("top-comments")
      ])
  }
}

// MARK: - Parser
extension Topic: Parsable {
  typealias AbstractType = Topic
}
