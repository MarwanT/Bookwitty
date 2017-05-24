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
    self.types = types

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
  struct Filter {
    //Different Filter Facets
    private static let categories = "categories"
    private static let languages = "languages"
    private static let types = "types"
    private static let limit: Int = 10

    private init(){}

    //Search API Facets Parameter
    static let dictionary = [
      categories : limit,
      languages :  limit,
      types : limit
    ]
  }
}
