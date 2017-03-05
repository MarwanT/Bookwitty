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
typealias Banner = (imageUrlString: String?, caption: String?)

class CuratedCollectionSections: NSObject {
  let banner: Banner?
  let featuredContent: [String]?
  let categories: [Category]?
  let readingListIdentifiers: [String]?
  let booksIdentifiers: [String]?
  let pagesIdentifiers: [String]?
  
  override init() {
    banner = nil
    featuredContent = nil
    categories = nil
    readingListIdentifiers = nil
    booksIdentifiers = nil
    pagesIdentifiers = nil
  }
  
  init(for dictionary: Dictionary<String,Any>) {
    let parsedValues = CuratedCollectionSections.sections(for: dictionary)
    self.banner = parsedValues.banner
    self.featuredContent = parsedValues.featuredContent
    self.categories = parsedValues.categories
    self.readingListIdentifiers = parsedValues.readingListIdentifiers
    self.booksIdentifiers = parsedValues.booksIdentifiers
    self.pagesIdentifiers = parsedValues.pagesIdentifiers
  }
  
  private static func sections(for dictionary: [String : Any]) -> (banner: Banner?, featuredContent: [String], categories: [Category], readingListIdentifiers: [String], booksIdentifiers: [String], pagesIdentifiers: [String]) {
    let json = JSON(dictionary)
    let banner: Banner? = nil
    let featuredContent = self.wittyIdentifiers(json: json["featured"])
    let categories = self.categories(json: json["categories"])
    let readingListsIdentifiers = self.wittyIdentifiers(json: json["reading-lists"])
    let booksIdentifiers = self.wittyIdentifiers(json: json["books"])
    let pagesIdentifiers = self.wittyIdentifiers(json: json["pages"])
    return (banner, featuredContent, categories, readingListsIdentifiers, booksIdentifiers, pagesIdentifiers)
  }
  
  private static func categories(json: JSON) -> [Category] {
    var categories = [Category]()
    for (_, subJSON) in json {
      let category = Category(key: subJSON.stringValue)
      categories.append(category)
    }
    return categories
  }
  
  private static func wittyIdentifiers(json: JSON) -> [String] {
    var identifiers = [String]()
    for (_, subJSON) in json {
      let identifier = subJSON["witty-id"].stringValue
      identifiers.append(identifier)
    }
    return identifiers
  }
}
