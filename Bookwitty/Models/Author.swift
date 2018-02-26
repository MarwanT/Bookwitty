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
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var imageUrl: String?
  var caption: String?
  var biography: String?
  var shortDescription: String?
  var profileImageUrl: String?
  var type: String?
  var penName: PenName?
  var vote: String?
  var counts: Counts?

  @objc
  private var reportedAsSpam: NSNumber?
  var isReported: Bool? {
    get {
      return ((reportedAsSpam?.intValue ?? 0) == 1)
    }
    set {
      reportedAsSpam = NSNumber(value: newValue ?? false)
    }
  }
  
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

  //TODO: add PageAuthor model we have a problem with the json-api conforming from the api siding
  @objc
  private var contributorsCollection: LinkedResourceCollection?
  lazy var contributors: [PenName]? = {
    return self.contributorsCollection?.resources as? [PenName]
  }()

  @objc
  fileprivate var countsDictionary: [String : Any]?

  override class var resourceType: ResourceType {
    return "authors"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "vote": Attribute().serializeAs("vote"),
      "userId": Attribute().serializeAs("user-id"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "imageUrl": Attribute().serializeAs("image-url"),
      "caption": Attribute().serializeAs("caption"),
      "biography": Attribute().serializeAs("biography"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "profileImageUrl": Attribute().serializeAs("profile-image-url"),
      "followingNumber": Attribute().serializeAs("following"),
      "reportedAsSpam": BooleanAttribute().serializeAs("reported-as-spam"),
      "type": Attribute().serializeAs("type"),
      "contributorsCollection" : ToManyRelationship(PenName.self).serializeAs("contributors"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

// MARK: - Parser
extension Author: Parsable {
  typealias AbstractType = Author
}
