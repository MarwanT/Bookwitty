//
//  PageAuthor.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class PageAuthor: Resource {

  var name: String?
  var imageUrl: String?
  var biography: String?
  var shortDescription: String?

  override class var resourceType: ResourceType {
    return "page-authors"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "imageUrl": Attribute().serializeAs("image-url"),
      "biography": Attribute().serializeAs("biography"),
      "shortDescription": Attribute().serializeAs("short-description")
      ])
  }
}

