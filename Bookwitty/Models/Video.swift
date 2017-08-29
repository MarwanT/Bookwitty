//
//  Video.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Video: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var type: String?
  var title: String?
  var shortDescription: String?
  var caption: String?
  var penName: PenName?
  var vote: String?
  var counts: Counts?
  var media: MediaModel?

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
    return "videos"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "type": Attribute().serializeAs("type"),
      "vote": Attribute().serializeAs("vote"),
      "title": Attribute().serializeAs("title"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "caption": Attribute().serializeAs("caption"),
      "media" : MediaAttribute().serializeAs("media"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "topVotesCollection" : ToManyRelationship(PenName.self).serializeAs("top-votes"),
      "topCommentsCollection" : ToManyRelationship(Comment.self).serializeAs("top-comments"),
      "tagsCollection" : ToManyRelationship(Tag.self).serializeAs("tags")
      ])
  }
}

// MARK: - Parser
extension Video: Parsable {
  typealias AbstractType = Video
}
