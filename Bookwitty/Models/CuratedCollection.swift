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
typealias Banner = (imageUrl: URL, caption: String)
typealias OnBoardingCollection =  [String : OnBoardingCollectionItem]

class CuratedCollectionSections: NSObject {
  let banner: Banner?
  let featuredContent: [String]?
  let categories: [Category]?
  let readingListIdentifiers: [String]?
  let booksIdentifiers: [String]?
  let pagesIdentifiers: [String]?
  let curatedCollectionOnBoardList: OnBoardingCollection?

  override init() {
    banner = nil
    featuredContent = nil
    categories = nil
    readingListIdentifiers = nil
    booksIdentifiers = nil
    pagesIdentifiers = nil
    curatedCollectionOnBoardList = nil
  }
  
  init(for dictionary: Dictionary<String,Any>) {
    let parsedValues = CuratedCollectionSections.sections(for: dictionary)
    self.banner = parsedValues.banner
    self.featuredContent = parsedValues.featuredContent
    self.categories = parsedValues.categories
    self.readingListIdentifiers = parsedValues.readingListIdentifiers
    self.booksIdentifiers = parsedValues.booksIdentifiers
    self.pagesIdentifiers = parsedValues.pagesIdentifiers
    self.curatedCollectionOnBoardList = parsedValues.curatedCollectionOnBoardList
  }
  
  private static func sections(for dictionary: [String : Any]) -> (banner: Banner?, featuredContent: [String], categories: [Category], readingListIdentifiers: [String], booksIdentifiers: [String], pagesIdentifiers: [String], curatedCollectionOnBoardList: OnBoardingCollection?) {
    let json = JSON(dictionary)
    let banner: Banner? = self.banner(json: json["banner-image"])
    let featuredContent = self.wittyIdentifiers(json: json["featured"])
    let categories = self.categories(json: json["categories"])
    let readingListsIdentifiers = self.wittyIdentifiers(json: json["reading-lists"])
    let booksIdentifiers = self.wittyIdentifiers(json: json["books"])
    let pagesIdentifiers = self.wittyIdentifiers(json: json["pages"])
    let curatedCollectionOnBoardList: [String : OnBoardingCollectionItem]? = self.onBoardList(json: json["onboard-list"])
    return (banner, featuredContent, categories, readingListsIdentifiers, booksIdentifiers, pagesIdentifiers, curatedCollectionOnBoardList)
  }
  
  private static func banner(json: JSON) -> Banner? {
    guard let imageURLString = json["url"].string,
      let imageURL = URL(string: imageURLString),
      let caption = json["caption"].string else {
        return nil
    }
    return (imageURL, caption)
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

  private static func onBoardList(json: JSON) -> OnBoardingCollection? {
    var identifiers: OnBoardingCollection = OnBoardingCollection()
    for subJSON in json {
      let key: String = subJSON.0
      let value: JSON = subJSON.1
      identifiers[key] = OnBoardingCollectionItem.parse(from: value)
    }
    return identifiers.count == 0 ? nil : identifiers
  }
}

struct OnBoardingCollectionItem {
  var featured: [CuratedCollectionItem]?
  var wittyIds: [CuratedCollectionItem]?
  var penNames: [String]?

  init(featured: [CuratedCollectionItem]? = nil, wittyIds: [CuratedCollectionItem]? = nil, penNames: [String]?  = nil) {
    self.featured = featured
    self.wittyIds = wittyIds
    self.penNames = penNames
  }

  static func parse(from json: JSON) -> OnBoardingCollectionItem {
    let featured: [CuratedCollectionItem]? = CuratedCollectionItem.parseArray(json: json["featured"])
    let wittyIds: [CuratedCollectionItem]? = CuratedCollectionItem.parseArray(json: json["witty-ids"])
    let penNames: [String]? = OnBoardingCollectionItem.parseStrings(json: json["pen-names"])

    return OnBoardingCollectionItem(featured: featured, wittyIds: wittyIds, penNames: penNames)
  }

  static private func parseStrings(json: JSON) -> [String]? {
    var values = [String]()
    for (_, subJSON) in json {
      let value = subJSON.stringValue
      values.append(value)
    }
    return values.count == 0 ? nil : values
  }
}

struct CuratedCollectionItem {
  var size: Int
  var caption: String
  var wittyId: String

  init(size: Int, caption: String, wittyId: String) {
    self.size = size
    self.caption = caption
    self.wittyId = wittyId
  }

  static func parse(from json: JSON) -> CuratedCollectionItem {
    let size: Int = json["size"].intValue
    let caption: String = json["caption"].stringValue
    let wittyId: String = json["witty-id"].stringValue
    return CuratedCollectionItem(size: size, caption: caption, wittyId: wittyId)
  }

  static func parseArray(json: JSON) -> [CuratedCollectionItem]? {
    var items = [CuratedCollectionItem]()
    for (_, subJSON) in json {
      items.append(CuratedCollectionItem.parse(from: subJSON))
    }
    return items.count == 0 ? nil : items
  }
}
