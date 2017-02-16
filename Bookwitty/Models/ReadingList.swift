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
  var createdAt: String?
  var updatedAt: String?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var title: String?
  var shortDescription: String?
  var conclusion: String?
  var body: String?
  //TODO: Check the full response for > relationships > posts model
  
  override class var resourceType: ResourceType {
    return "reading-lists"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "createdAt": Attribute().serializeAs("created-at"),
      "updatedAt": Attribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "conclusion": Attribute().serializeAs("conclusion"),
      "body": Attribute().serializeAs("body")
      ])
  }
}

