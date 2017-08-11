//
//  Tag.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/11.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Tag: Resource {

  var slug: String?
  var title: String?

  @objc
  private var followingNumber: NSNumber?
  var following: Bool {
    get {
      return ((followingNumber?.intValue ?? 0) == 1)
    }
    set {
      followingNumber = NSNumber(value: newValue)
    }
  }

  override class var resourceType: ResourceType {
    return "tags"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "slug": Attribute().serializeAs("slug"),
      "title": Attribute().serializeAs("title"),
      "followingNumber": Attribute().serializeAs("following"),
      ])
  }
}

// MARK: - Parser
extension Tag: Parsable {
  typealias AbstractType = Tag
}
