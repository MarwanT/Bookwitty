//
//  Counts.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class Counts: NSObject {
  private struct CountsKey {
    private init(){}
    static let children = "children"
    static let followers = "followers"
    static let contributors = "contributors"
    static let comments = "comments"
    static let relatedLinks = "related-links"
    static let wits = "wits"
    static let commenters = "commenters"
  }

  func isValid() -> Bool {
    return (
      (children ?? 0) > 0 ||
      (comments ?? 0) > 0 ||
      (wits ?? 0) > 0 ||
      (relatedLinks?.count ?? 0) > 0 ||
      (followers ?? 0) > 0 ||
      (contributors ?? 0) > 0 ||
      (posts ?? 0) > 0 ||
      (commenters ?? 0) > 0
    )
  }

  var children: Int?
  var comments: Int?
  var commenters: Int?
  var wits: Int?
  var relatedLinks: [String : NSNumber]?
  var followers: Int?
  var contributors: Int?
  //Calculated from related-Links while parsing
  var posts: Int?

  override init() {
    super.init()
  }

  init(for dictionary: [String : Any]) {
    super.init()
    setValues(dictionary: dictionary)
  }

  private func setValues(dictionary: [String : Any]) {
    self.children = (dictionary[CountsKey.children] as? NSNumber)?.intValue
    self.wits = (dictionary[CountsKey.wits] as? NSNumber)?.intValue
    self.commenters = (dictionary[CountsKey.commenters] as? NSNumber)?.intValue
    self.comments = (dictionary[CountsKey.comments] as? NSNumber)?.intValue
    self.contributors = (dictionary[CountsKey.contributors] as? NSNumber)?.intValue
    self.followers = (dictionary[CountsKey.followers]  as? NSNumber)?.intValue
    self.relatedLinks = dictionary[CountsKey.relatedLinks] as? [String : NSNumber]

    if let relatedLinks = relatedLinks {
      let values = Array(relatedLinks.values)
      self.posts = values.reduce(0) { (cumulative, current: NSNumber) -> Int in
        return cumulative + current.intValue
      }
    }
  }

  override var debugDescription: String {
    let str1: String = "comments/commenters:" + " " + String(comments ?? -1) + " / " + String(commenters ?? -1)
    let str2: String =  "wits" + " " + String(wits ?? -1)
    let str3: String = "followers/contributors:" + " " + String(followers ?? -1) + " / " + String(contributors ?? -1)
    let str: String = str1 + " || " + str2 + " || " + str3
    return str
  }
}
