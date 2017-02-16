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
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var body: String?
  var shortDescription: String?
  var title: String?
  var type: String?

  override class var resourceType: ResourceType {
    return "texts"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "body": Attribute().serializeAs("body"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type")
      ])
  }
}

