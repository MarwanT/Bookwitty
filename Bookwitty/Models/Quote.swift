//
//  Quote.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Quote: Resource {
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var body: String?
  var author: String?
  var title: String?
  var type: String?

  override class var resourceType: ResourceType {
    return "quotes"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "body": Attribute().serializeAs("body"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "author": Attribute().serializeAs("author")
      ])
  }
}

