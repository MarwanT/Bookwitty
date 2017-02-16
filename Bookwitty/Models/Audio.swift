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
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var type: String?
  var title: String?
  var shortDescription: String?
  var caption: String?
  //TODO: Check if media_link is a related object or a dictionary
  var media: [String: Any]?

  override class var resourceType: ResourceType {
    return "audios"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "caption": Attribute().serializeAs("caption"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "media": Attribute().serializeAs("media")
      ])
  }
}

// MARK: - Parser
extension Audio: Parsable {
  typealias AbstractType = Audio
}
