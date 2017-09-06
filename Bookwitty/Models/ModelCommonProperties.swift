//
//  ModelCommonProperties.swift
//  Bookwitty
//
//  Created by Marwan  on 2/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

protocol ModelCommonProperties: class {
  var id: String? { get }
  var title: String? { get }
  var createdAt: NSDate? { get }
  var updatedAt: NSDate? { get }
  var thumbnailImageUrl: String? { get }
  var coverImageUrl: String? { get }
  var shortDescription: String? { get }
  var vote: String? { get }
  var isWitted: Bool { get }
  var following: Bool { get }
  var canonicalURL: URL? { get }
  var counts: Counts? { get set }
  var topComments: [Comment]? { get set }

  var registeredResourceType: ResourceType { get }
  var penName: PenName? { get set }
  var contributors: [PenName]? { get set }

  var topVotes: [Vote]? { get set }
  var witters: String? { get }

  var tags: [Tag]? { get set }
  var tagsRelations: [ResourceIdentifier]? { get }

  func sameInstanceAs(newResource: ModelCommonProperties?) -> Bool?
}

extension ModelCommonProperties {
  var witters: String? {
    let wits = self.counts?.wits ?? 0
    guard wits > 0 else {
      return nil
    }

    let typesWithoutWit = [
      Topic.resourceType,
      Author.resourceType,
      Book.resourceType,
      PenName.resourceType
    ]

    guard !typesWithoutWit.contains(self.registeredResourceType) else {
      return nil
    }

    let voters: [String] = self.topVotes?
      .filter({
      guard let penName = $0.penName else { return false }
      return !UserManager.shared.isMyDefault(penName: penName) })
      .flatMap({ $0.penName?.name }) ?? []

    var names = voters.prefix(2)

    if isWitted {
      names.insert(Strings.you(), at: 0)
    }

    let witters: String
    let othersCount = max(wits - names.count, 0)
    let separator = ", "

    switch (names.count, othersCount) {
    case (0, _):
      witters = Strings.findThisWitty(witters: wits)
    case (let count, 0):
      if count == 1 && isWitted {
        witters = Strings.you_find_witty()
      } else {
        witters = Strings.findThisWitty(witters: names.joined(separator: separator), count: count)
      }
    default:
      witters = Strings.andOthersFindThisWitty(witters: names.joined(separator: separator), others: othersCount)
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

  var topVotes: [Vote]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tags: [Tag]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tagsRelations: [ResourceIdentifier]? {
    return nil
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

  var topVotes: [Vote]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var topComments: [Comment]? {
    get { return nil }
    set { /*Not a valid property of model*/ }
  }

  var tags: [Tag]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tagsRelations: [ResourceIdentifier]? {
    return nil
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

  var topVotes: [Vote]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var topComments: [Comment]? {
    get { return nil }
    set { /*Not a valid property of model*/ }
  }

  var tags: [Tag]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tagsRelations: [ResourceIdentifier]? {
    return nil
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

  var topComments: [Comment]? {
    get { return nil }
    set { /*Not a valid property of model*/ }
  }

  var vote: String? {
    return nil
  }

  var isWitted: Bool {
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

  var topVotes: [Vote]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tags: [Tag]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tagsRelations: [ResourceIdentifier]? {
    return nil
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

  var topComments: [Comment]? {
    get { return nil }
    set { /*Not a valid property of model*/ }
  }

  var isWitted: Bool {
    guard let vote = vote else {
      return false
    }
    return Vote.isWitted(vote: vote)
  }
  
  var following: Bool {
    return false
  }

  var topVotes: [Vote]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }

  var tags: [Tag]? {
    get { return nil }
    set { /* Not a valid property of model */ }
  }
  
  var tagsRelations: [ResourceIdentifier]? {
    return nil
  }
}
