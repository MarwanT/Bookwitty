//
//  ProductForm.swift
//  Bookwitty
//
//  Created by Marwan  on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct ProductForm {
  var key: String
  var value: String
  
  init?() {
    self.init(key: "", value: "")
  }
  
  init?(key: String, value: String) {
    guard !key.isBlank else {
      return nil
    }
    self.key = key
    self.value = value
  }
}
