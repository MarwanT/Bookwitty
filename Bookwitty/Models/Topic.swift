//
//  Topic.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Topic: Resource {
  var createdAt: NSDate?
  var updatedAt: NSDate?
  var userId: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?
  var shortDescription: String?
  var longDescription: String?
  var title: String?
  var penName: PenName?
  var vote: String?

  var canonicalURL: URL? {
    guard let urlString = self.links?["canonical-url"] as? String,
      let url = URL(string: urlString) else {
        return nil
    }
    return url
  }
  
  @objc
  private var contributorsCollection: LinkedResourceCollection?
  lazy var contributors: [PenName]? = {
    return self.contributorsCollection?.resources as? [PenName]
  }()

  @objc
  fileprivate var countsDictionary: [String : Any]?
  
  override class var resourceType: ResourceType {
    return "topics"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "createdAt": DateAttribute().serializeAs("created-at"),
      "updatedAt": DateAttribute().serializeAs("updated-at"),
      "userId": Attribute().serializeAs("user-id"),
      "vote": Attribute().serializeAs("vote"),
      "thumbnailImageUrl": Attribute().serializeAs("thumbnail-image-url"),
      "coverImageUrl": Attribute().serializeAs("cover-image-url"),
      "shortDescription": Attribute().serializeAs("short-description"),
      "longDescription": Attribute().serializeAs("description"),
      "countsDictionary": Attribute().serializeAs("counts"),
      "title": Attribute().serializeAs("title"),
      "penName" : ToOneRelationship(PenName.self).serializeAs("pen-name"),
      "contributorsCollection" : ToManyRelationship(PenName.self).serializeAs("contributors"),
      ])
  }
}

//MARK: - Counts Helpers
extension Topic {
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
extension Topic: Parsable {
  typealias AbstractType = Topic
}
