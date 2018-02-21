//
//  ReadingLists.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class ReadingList: Resource {
  var name: String?
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var title: String?
  var shortDescription: String?
  var conclusion: String?
  var body: String?
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
  private var topVotesCollection: LinkedResourceCollection?
  lazy var topVotes: [Vote]? = {
    return self.topVotesCollection?.resources as? [Vote]
  }()

  var postsCollection: LinkedResourceCollection?
  lazy var postsRelations: [ResourceIdentifier]? = {
    return self.postsCollection?.linkage
  }()

  lazy var posts: [ModelResource]? = {
    return self.postsCollection?.resources
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
    return "reading-lists"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "vote": Attribute().serializeAs("vote"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "conclusion": Attribute().serializeAs("conclusion"),
      "body": Attribute().serializeAs("body"),
      "reportedAsSpam": BooleanAttribute().serializeAs("reported-as-spam"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "postsCollection" : ToManyRelationship(Resource.self).serializeAs("posts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "topVotesCollection" : ToManyRelationship(PenName.self).serializeAs("top-votes"),
      "topCommentsCollection" : ToManyRelationship(Comment.self).serializeAs("top-comments"),
      "tagsCollection" : ToManyRelationship(Tag.self).serializeAs("tags")
      ])
  }
}

// MARK: - Parser
extension ReadingList: Parsable {
  typealias AbstractType = ReadingList
}
