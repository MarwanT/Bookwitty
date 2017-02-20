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
  
  override class var resourceType: ResourceType {
    return "curated-collections"
  }
  
  override class var fields: [Field] {
    return fieldsFromDictionary([
      "title" : Attribute().serializeAs("title"),
      "language" : Attribute().serializeAs("language"),
      "region" : Attribute().serializeAs("region"),
      ])
  }
}

extension CuratedCollection: Parsable {
  typealias AbstractType = CuratedCollection
}




// MARK: - Curated collection sections

typealias FeaturedContent = (wittyId: String?, caption: String?)

class CuratedCollectionSections: NSObject {
  let featuredContent: [FeaturedContent]?
  let categories: [Category]?
  let readingListIdentifiers: [String]?
  
  override init() {
    featuredContent = nil
    categories = nil
    readingListIdentifiers = nil
  }
}
