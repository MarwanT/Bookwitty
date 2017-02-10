//
//  CategoryManager.swift
//  Bookwitty
//
//  Created by Marwan  on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CategoryManager {
  
  static let shared: CategoryManager = CategoryManager()
  private init() {
  }
  
  
  func categoriesFromDictionary(fromDictionary dictionary: [String: Any], parentKeys: [String]? = nil) -> [Category] {
    var categories = [Category]()
    
    for (key, value) in dictionary {
      guard let valuesDictionary = value as? [String: Any],
        let name = valuesDictionary["name"] as? String else {
          continue
      }
      
      var currentKeys = parentKeys ?? [String]()
      currentKeys.append(key)
      let categoryKey = currentKeys.joined(separator: ".")
      
      var subcategories: [Category]? = nil
      var subcategoriesDictionary = valuesDictionary
      subcategoriesDictionary.removeValue(forKey: "name")
      if subcategoriesDictionary.count > 0 {
        subcategories = categoriesFromDictionary(fromDictionary: subcategoriesDictionary, parentKeys: currentKeys)
      }
      
      categories.append(Category(key: categoryKey, value: name, subcategories: subcategories))
    }
    
    return categories
  }
}
