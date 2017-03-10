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
  var title: String?
  var type: String?
  var penName: PenName?
  var vote: String?

  @objc
  private var followingNumber: NSNumber?
  var following: Bool {
    return ((followingNumber?.intValue ?? 0) == 1)
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
      "countsDictionary": Attribute().serializeAs("counts"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "profileImageUrl": Attribute().serializeAs("profile-image-url"),
      "title": Attribute().serializeAs("title"),
      "followingNumber": Attribute().serializeAs("following"),
      "type": Attribute().serializeAs("type"),
      "contributorsCollection" : ToManyRelationship(PenName.self).serializeAs("contributors"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name")
      ])
  }
}

//MARK: - Counts Helpers
extension Author {
  private struct CountsKey {
    private init(){}
    static let followers = "followers"
    static let contributors = "contributors"
    static let comments = "comments"
    static let relatedLinks = "related-links"
  }

  var counts: (contributors: Int?, followers: Int?, posts: Int?) {
    guard let counts = countsDictionary else {
      return (nil, nil, nil)
    }

    let contributors = (counts[CountsKey.contributors] as? NSNumber)?.intValue
    let followers = (counts[CountsKey.followers] as? NSNumber)?.intValue
    let relatedLinks = counts[CountsKey.relatedLinks] as? [String : NSNumber]

    var posts: Int? = nil

    if let relatedLinks = relatedLinks {
      let values = Array(relatedLinks.values)
      posts = values.reduce(0) { (cumulative, current: NSNumber) -> Int in
        return cumulative + current.intValue
      }
    }
    return (contributors, followers, posts)
  }
}

// MARK: - Parser
extension Author: Parsable {
  typealias AbstractType = Author
}
