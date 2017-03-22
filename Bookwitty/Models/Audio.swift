//
//  Audio.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Audio: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var type: String?
  var title: String?
  var shortDescription: String?
  var caption: String?
  //TODO: Check if media_link is a related object or a dictionary
  var media: MediaModel?
  var penName: PenName?
  var vote: String?
  var counts: Counts?

  override class var resourceType: ResourceType {
    return "audios"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "caption": Attribute().serializeAs("caption"),
      "vote": Attribute().serializeAs("vote"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "media": MediaAttribute().serializeAs("media"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Audio: Parsable {
  typealias AbstractType = Audio
}
