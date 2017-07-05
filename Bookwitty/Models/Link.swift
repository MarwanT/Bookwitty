//
//  Link.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Link: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var urlLink: String?
  var title: String?
  var shortDescription: String?
  var type: String?
  var penName: PenName?
  var vote: String?
  var counts: Counts?

  @objc
  private var topVotesCollection: LinkedResourceCollection?
  lazy var topVotes: [Vote]? = {
    return self.topVotesCollection?.resources as? [Vote]
  }()

  override class var resourceType: ResourceType {
    return "links"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "urlLink": Attribute().serializeAs("url"),
      "title": Attribute().serializeAs("title"),
      "vote": Attribute().serializeAs("vote"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "type": Attribute().serializeAs("type"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "topVotesCollection" : ToManyRelationship(PenName.self).serializeAs("top-votes")
      ])
  }
}

// MARK: - Parser
extension Link: Parsable {
  typealias AbstractType = Link
}
