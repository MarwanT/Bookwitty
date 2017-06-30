//
//  Vote.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Vote: Resource {
  var value: Bool?
  var penName: PenName?

  override class var resourceType: ResourceType {
    return "votes"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "vote": Attribute().serializeAs("value"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      ])
  }
}

// MARK: - Parser
extension Vote: Parsable {
  typealias AbstractType = Vote
}
