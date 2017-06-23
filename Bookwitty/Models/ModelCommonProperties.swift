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
  var counts: Counts? { get set }

  var registeredResourceType: ResourceType { get }
  var penName: PenName? { get set }
  var contributors: [PenName]? { get set }

  var witters: String? { get }

  func sameInstanceAs(newResource: ModelCommonProperties?) -> Bool?
}

extension ModelCommonProperties {
  var witters: String? {
    let wits = self.counts?.wits ?? 0
    guard wits > 0 else {
      return nil
    }

    var names: [String] = []
    if isWitted {
      names.insert(Strings.you() , at: 0)
    }

    let witters: String
    if names.count > 0 {
      let othersCount = max(wits - names.count, 0)
      witters = Strings.andOthersFindThisWitty(witters: names.joined(separator: ","), others: othersCount)
    } else {
      witters = Strings.findThisWitty(witters: wits)
    }

    return witters
  }

  func sameInstanceAs(newResource: ModelCommonProperties?) -> Bool? {
    guard let existingResource = self as? ModelResource, let newResource = newResource as? ModelResource else {
      return nil
    }
    return existingResource === newResource
  }
}

extension Video: ModelCommonProperties {
   var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }

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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }

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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }

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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }
  
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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }

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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }
  
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
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }

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
    get {
      return nil
    }
    set {
      //Property does not apply
    }
  }
}

extension PenName: ModelCommonProperties {
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }
  
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
    get {
      return nil
    }
    set {
      //Property does not apply
    }
  }
}

extension Comment: ModelCommonProperties {
  var thumbnailImageUrl: String? {
    return nil
  }
  
  var coverImageUrl: String? {
    return nil
  }
  
  var title: String? {
    return nil
  }
  
  var shortDescription: String? {
    return nil
  }
  
  var contributors: [PenName]? {
    get { return nil }
    set {
      //Not a valid property of model
    }
  }
  
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
