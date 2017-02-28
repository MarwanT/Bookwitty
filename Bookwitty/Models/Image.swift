//
//  Image.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Image: Resource {
  var createdAt: NSDate?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var caption: String?
  var shortDescription: String?
  var title: String?
  var type: String?
  var media: [String: Any]?
  var penName: PenName?

  override class var resourceType: ResourceType {
    return "images"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "caption": Attribute().serializeAs("caption"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "media": Attribute().serializeAs("media"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Image: Parsable {
  typealias AbstractType = Image
}
