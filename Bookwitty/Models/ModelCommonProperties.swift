//
//  ModelCommonProperties.swift
//  Bookwitty
//
//  Created by Marwan  on 2/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

enum Vote: String {
  case witted = "wit"
  case dimmed = "dim"
  case none = ""

  static func isWitted(vote: String) -> Bool {
    return vote == Vote.witted.rawValue
  }

  static func isDimmed(vote: String) -> Bool {
    return vote == Vote.dimmed.rawValue
  }
}

protocol ModelCommonProperties {
  var id: String? { get }
  var title: String? { get }
  var createdAt: NSDate? { get }
  var updatedAt: NSDate? { get }
  var thumbnailImageUrl: String? { get }
  var coverImageUrl: String? { get }
  var shortDescription: String? { get }
  var vote: String? { get }
  var isWitted: Bool { get }
  var isDimmed: Bool { get }
  var following: Bool { get }
  var canonicalURL: URL? { get }
  var counts: Counts? { get }

  var registeredResourceType: ResourceType { get }
  var penName: PenName? { get }

  func sameInstanceAs(newResource: ModelCommonProperties?) -> Bool?
}

extension ModelCommonProperties {
  func sameInstanceAs(newResource: ModelCommonProperties?) -> Bool? {
    guard let existingResource = self as? ModelResource, let newResource = newResource as? ModelResource else {
      return nil
    }
    return existingResource === newResource
  }
}

extension Video: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension Topic: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }
}

extension Image: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension Author: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }
}

extension Link: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension ReadingList: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension Audio: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension Text: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }
}

extension Quote: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  var isDimmed: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isDimmed(vote: vote)
  }

  var following: Bool {
    return false
  }

  var shortDescription: String? { return nil }
}

extension Book: ModelCommonProperties {
  var vote: String? {
    return nil
  }
  
  var isWitted: Bool {
    return false
  }
  var isDimmed: Bool {
    return false
  }

  var shortDescription: String? {
    return nil
  }

  var penName: PenName? {
    return nil
  }
}

extension PenName: ModelCommonProperties {
  var title: String? {
    return name
  }

  var shortDescription: String? {
    return biography
  }

  var thumbnailImageUrl: String? {
    return avatarUrl
  }

  var createdAt: NSDate? {
    return nil
  }

  var updatedAt: NSDate? {
    return nil
  }

  var coverImageUrl: String? {
    return nil
  }

  var vote: String? {
    return nil
  }

  var isWitted: Bool {
    return false
  }

  var isDimmed: Bool {
    return false
  }

  var penName: PenName? {
    return nil
  }
}
