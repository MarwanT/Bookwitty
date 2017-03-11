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
  var canonicalURL: URL? { get }
}

extension Video: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Topic: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Image: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Author: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Link: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension ReadingList: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Audio: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Text: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
}

extension Quote: ModelCommonProperties {
  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
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

  var shortDescription: String? {
    return nil
  }
}
