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
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var body: String?
  var shortDescription: String?
  var title: String?
  var type: String?
  var penName: PenName?
  var vote: String?

  var canonicalURL: URL? {
    guard let urlString = self.links?["canonical-url"] as? String,
      let url = URL(string: urlString) else {
        return nil
    }
    return url
  }
  
  override class var resourceType: ResourceType {
    return "texts"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "vote": Attribute().serializeAs("vote"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "body": Attribute().serializeAs("body"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "title": Attribute().serializeAs("title"),
      "type": Attribute().serializeAs("type"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Text: Parsable {
  typealias AbstractType = Text
}
