//
//  CategoriesTableViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class CategoriesTableViewModel {
  let viewControllerTitle = localizedString(key: "categories", defaultValue: "Categories")
  
  var categories: [Category]
  
  init () {
    categories = CategoryManager.shared.categories ?? [Category]()
  }
  
  var numberOfSections: Int {
    return categories.count > 0 ? 1 : 0
  }
  
  func numberOfRowsForSection(section: Int) -> Int {
    return categories.count
  }
  
  func data(forCellAtIndexPath index: IndexPath) -> String {
    return categories[index.row].value ?? "Discover"
  }
  
  func category(forCellAtIndexPath index: IndexPath) -> Category {
    return categories[index.row]
  }
}
