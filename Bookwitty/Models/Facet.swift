//
//  Facet.swift
//  Bookwitty
//
//  Created by charles on 5/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class Facet {
  var categories: [Category]?
  var languages: [String]?
  var types: [String]?

  fileprivate var categoriesCodes: [String]?

  init(categories: [String]?, languages: [String]?, types: [String]?) {
    self.categoriesCodes = categories
    self.languages = languages
    self.types = types?.filter({ Parser.sharedInstance.registeredResourceTypes.contains($0) })

    if let codes = categoriesCodes {
      self.categories = CategoryManager.shared.categories(from: codes)
    }
  }

  convenience init(from dictionary: [String : Any]) {
    let categories = (dictionary["categories"] as? [[String : Any]])?.map({ $0["term"] }) as? [String]
    let languages = (dictionary["languages"] as? [[String : Any]])?.map({ $0["term"] }) as? [String]
    let types = (dictionary["types"] as? [[String : Any]])?.map({ $0["term"] }) as? [String]
    self.init(categories: categories, languages: languages, types: types)
  }
}

extension Facet {
  //Different Filter Facets
  enum Options: String {
    case categories = "categories"
    case languages = "languages"
    case types = "types"
  }

  struct Filter {
    private static let limit: Int = 10
    private init(){}
    
    //Search API Facets Parameter
    static let dictionary = [
      Options.categories.rawValue : limit,
      Options.languages.rawValue :  limit,
      Options.types.rawValue : limit
    ]
  }
}
