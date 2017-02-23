//
//  CuratedCollection.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine
import SwiftyJSON


class CuratedCollection: Resource {
  var title: String?
  var language: String?
  var region: String?
  var sections: CuratedCollectionSections?
  
  override class var resourceType: ResourceType {
    return "curated-collections"
  }
  
  override class var fields: [Field] {
    return fieldsFromDictionary([
      "title" : Attribute().serializeAs("title"),
      "language" : Attribute().serializeAs("language"),
      "region" : Attribute().serializeAs("region"),
      "sections" : CuratedCollectionSectionsAttribute().serializeAs("sections")
      ])
  }
}

extension CuratedCollection: Parsable {
  typealias AbstractType = CuratedCollection
}




// MARK: - Curated collection sections

typealias FeaturedContent = (wittyId: String?, caption: String?)
typealias Banner = (imageUrlString: String?, caption: String?)

class CuratedCollectionSections: NSObject {
  let featuredContent: [FeaturedContent]?
  let categories: [Category]?
  let readingListIdentifiers: [String]?
  
  override init() {
    featuredContent = nil
    categories = nil
    readingListIdentifiers = nil
  }
  
  init(for dictionary: Dictionary<String,Any>) {
    let parsedValues = CuratedCollectionSections.sections(for: dictionary)
    self.featuredContent = parsedValues.featuredContent
    self.categories = parsedValues.categories
    self.readingListIdentifiers = parsedValues.readingListIdentifiers
  }
  
  private static func sections(for dictionary: [String : Any]) -> (featuredContent: [FeaturedContent], categories: [Category], readingListIdentifiers: [String]) {
    let json = JSON(dictionary)
    let featuredContent = self.featuredContent(json: json["featured"])
    let categories = self.categories(json: json["categories"])
    let readingListsIdentifiers = self.readingListIdentifiers(json: json["reading-lists"])
    return (featuredContent, categories, readingListsIdentifiers)
  }
  
  private static func featuredContent(json: JSON) -> [FeaturedContent] {
    var featured = [FeaturedContent]()
    for (_, subJSON) in json {
      let identifier = subJSON["witty-id"].stringValue
      let caption = subJSON["caption"].stringValue
      featured.append((identifier, caption))
    }
    return featured
  }
  
  private static func categories(json: JSON) -> [Category] {
    var categories = [Category]()
    for (_, subJSON) in json {
      let category = Category(key: subJSON.stringValue)
      categories.append(category)
    }
    return categories
  }
  
  private static func readingListIdentifiers(json: JSON) -> [String] {
    var identifiers = [String]()
    for (_, subJSON) in json {
      let identifier = subJSON["witty-id"].stringValue
      identifiers.append(identifier)
    }
    return identifiers
  }
}
