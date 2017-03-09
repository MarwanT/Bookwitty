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
  
  static let shared: CategoryManager = CategoryManager()
  private init() {
    loadCategoriesFromJSON()
  }
  
  private func categoriesLanguage() -> String {
    var language = "en"
    guard let preferredLanguage = NSLocale.preferredLanguages.first else {
      return language
    }
    
    switch preferredLanguage {
    // TODO: detect french language and assign it here when available
    case "en":
      language = preferredLanguage
    default:
      break
    }
    
    return language
  }
  
  private func loadCategoriesFromJSON() {
    let language = categoriesLanguage()
    
    guard let url = Bundle.main.url(forResource: "Categories." + language, withExtension: "json") else {
      print("Fail to get categories file path")
      return
    }
    
    guard let data = try? Data(contentsOf: url),
      let dictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
        print("Fail to load dictionary from categories file")
        return
    }
    
    guard let categoriesDictionary = dictionary?[language] as? [String : Any] else {
      print("Fail to load localized categories")
      return
    }
    
    categories = categoriesFromDictionary(fromDictionary: categoriesDictionary)
  }
  
  
  private func categoriesFromDictionary(fromDictionary dictionary: [String: Any], parentKeys: [String]? = nil) -> [Category] {
    var categories = [Category]()
    
    for (key, value) in dictionary {
      guard let valuesDictionary = value as? [String: Any],
        let name = valuesDictionary["name"] as? String else {
          continue
      }
      
      var currentKeys = parentKeys ?? [String]()
      currentKeys.append(key)
      let categoryKey = currentKeys.joined(separator: "")
      
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
  
  /// Returns Category object out of sent ids if available
  /// ids with no matching local category won't be included in the 
  /// Returned result
  func categories(from identifiers: [String]) -> [Category] {
    var categoriesArray = [Category]()
    for identifier in identifiers {
      guard let category = category(from: identifier) else {
        continue
      }
      categoriesArray.append(category)
    }
    return categoriesArray
  }
  
  func category(from identifier: String) -> Category? {
    guard let categories = categories else {
      return nil
    }
    let identifiersTree = categoryIdentifiersTree(for: identifier)
    return leefCategory(index: 0, categoryIdentifiers: identifiersTree, categories: categories)
  }
  
  private func categoryIdentifiersTree(for identifier: String) -> [String] {
    let identifierCharacters = Array(identifier.characters)
    var identifiersTree = [String]()
    for (index, character) in identifierCharacters.enumerated() {
      if index == 0 {
        identifiersTree.append(String(character))
        continue
      }
      let previousIdentifier = identifiersTree[index-1]
      identifiersTree.append(previousIdentifier+String(character))
    }
    return identifiersTree
  }
  
  private func leefCategory(index: Int, categoryIdentifiers: [String], categories: [Category]) -> Category? {
    let identifier = categoryIdentifiers[index]
    guard let category = categories.filter({ $0.key == identifier }).first else {
      return nil
    }
    if index == (categoryIdentifiers.count - 1) {
      return category
    } else {
      guard let subcategories = category.subcategories else {
        return nil
      }
      return leefCategory(index: index+1, categoryIdentifiers: categoryIdentifiers, categories: subcategories)
    }
  }
}
