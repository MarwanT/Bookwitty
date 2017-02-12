//
//  CategoryManager.swift
//  Bookwitty
//
//  Created by Marwan  on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CategoryManager {
  var categories: [Category]? = nil
  private var localID: String = "en"
  
  static let shared: CategoryManager = CategoryManager()
  private init() {
    loadCategoriesFromJSON()
  }
  
  private func loadCategoriesFromJSON() {
    guard let url = Bundle.main.url(forResource: "Categories", withExtension: "json") else {
      print("Fail to get categories file path")
      return
    }
    
    guard let data = try? Data(contentsOf: url),
      let dictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
        print("Fail to load dictionary from categories file")
        return
    }
    
    guard let categoriesDictionary = dictionary?[localID] as? [String : Any] else {
      print("Fail to load localized categories")
      return
    }
    
    categories = categoriesFromDictionary(fromDictionary: categoriesDictionary)
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
