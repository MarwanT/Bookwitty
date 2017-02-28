//
//  Author.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Author: Resource {
  var name: String?
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var imageUrl: String?
  var caption: String?
  var biography: String?
  var shortDescription: String?
  var profileImageUrl: String?
  var title: String?
  var type: String?
  var penName: PenName?
  //TODO: add PageAuthor model we have a problem with the json-api conforming from the api siding

  override class var resourceType: ResourceType {
    return "authors"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "imageUrl": Attribute().serializeAs("image-url"),
      "caption": Attribute().serializeAs("caption"),
      "biography": Attribute().serializeAs("biography"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "profileImageUrl": Attribute().serializeAs("profile-image-url"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Author: Parsable {
  typealias AbstractType = Author
}
