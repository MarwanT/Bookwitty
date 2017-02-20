//
//  Category.swift
//  Bookwitty
//
//  Created by Marwan  on 2/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class Category {
  var key: String?
  var value: String?
  var subcategories: [Category]?
  
  convenience init() {
    self.init(key: nil, value: nil, subcategories: nil)
  }
  
  init(key: String?, value: String? = nil, subcategories: [Category]? = nil) {
    self.key = key
    self.value = value
    self.subcategories = subcategories
  }
}
