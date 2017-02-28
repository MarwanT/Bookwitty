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
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var type: String?
  var title: String?
  var shortDescription: String?
  var caption: String?
  var penName: PenName?

  override class var resourceType: ResourceType {
    return "videos"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "type": Attribute().serializeAs("type"),
      "title": Attribute().serializeAs("title"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "caption": Attribute().serializeAs("caption"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Video: Parsable {
  typealias AbstractType = Video
}
