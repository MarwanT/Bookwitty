//
//  PenName.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class PenName: Resource {
  var name: String?
  var biography: String?
  var avatarUrl: String?
  var facebookUrl: String?
  var tumblrUrl: String?
  var googlePlusUrl: String?
  var twitterUrl: String?
  var instagramUrl: String?
  var pinterestUrl: String?
  var youtubeUrl: String?
  var linkedinUrl: String?
  var wordpressUrl: String?
  var websiteUrl: String?
  var followersCount: NSNumber?
  var followingCount: NSNumber?

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
    return "pen-names"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "name": Attribute().serializeAs("name"),
      "biography": Attribute().serializeAs("biography"),
      "avatarUrl": Attribute().serializeAs("avatar-url"),
      "facebookUrl": Attribute().serializeAs("facebook-url"),
      "tumblrUrl": Attribute().serializeAs("tumblr-url"),
      "googlePlusUrl": Attribute().serializeAs("google-plus"),
      "twitterUrl": Attribute().serializeAs("twitter-url"),
      "instagramUrl": Attribute().serializeAs("instagram-url"),
      "pinterestUrl": Attribute().serializeAs("pinterest-url"),
      "youtubeUrl": Attribute().serializeAs("youtube-url"),
      "linkedinUrl": Attribute().serializeAs("linkedin-url"),
      "wordpressUrl": Attribute().serializeAs("wordpress-url"),
      "websiteUrl": Attribute().serializeAs("website-url"),
      "followingNumber": Attribute().serializeAs("following"),
      "followersCount": Attribute().serializeAs("followers-count"),
      "followingCount": Attribute().serializeAs("following-count")
      ])
  }
}

// MARK: - Parser
extension PenName: Parsable {
  typealias AbstractType = PenName
}
