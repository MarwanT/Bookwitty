//
//  Text.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Text: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var body: String?
  var shortDescription: String?
  var title: String?
  var type: String?
  var penName: PenName?
  var vote: String?
  var counts: Counts?
  var status: String?
  
  @objc
  private var topVotesCollection: LinkedResourceCollection?
  lazy var topVotes: [Vote]? = {
    return self.topVotesCollection?.resources as? [Vote]
  }()

  @objc
  private var topCommentsCollection: LinkedResourceCollection?
  lazy var topComments: [Comment]? = {
    return self.topCommentsCollection?.resources as? [Comment]
  }()

  @objc
  private var tagsCollection: LinkedResourceCollection?
  lazy var tagsRelations: [ResourceIdentifier]? = {
    return self.tagsCollection?.linkage
  }()
  lazy var tags: [Tag]? = {
    return self.tagsCollection?.resources as? [Tag]
  }()

  override class var resourceType: ResourceType {
    return "texts"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "status": Attribute().serializeAs("status"),
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "vote": Attribute().serializeAs("vote"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "body": Attribute().serializeAs("body"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "topVotesCollection" : ToManyRelationship(PenName.self).serializeAs("top-votes.pen-name"),
      "topCommentsCollection" : ToManyRelationship(Comment.self).serializeAs("top-comments"),
      "tagsCollection" : ToManyRelationship(Tag.self).serializeAs("tags")
      ])
  }
}

// MARK: - Parser
extension Text: Parsable {
  typealias AbstractType = Text
}
