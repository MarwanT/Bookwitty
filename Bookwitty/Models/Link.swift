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
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var urlLink: String?
  var title: String?
  var shortDescription: String?
  var type: String?

  override class var resourceType: ResourceType {
    return "links"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "urlLink": Attribute().serializeAs("url"),
      "title": Attribute().serializeAs("title"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "type": Attribute().serializeAs("type")
      ])
  }
}

// MARK: - Parser
extension Link: Parsable {
  typealias AbstractType = Link
}
