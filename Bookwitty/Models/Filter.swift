//
//  Filter.swift
//  Bookwitty
//
//  Created by charles on 5/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

public class Filter {
  var query: String?

  var categories: [Category]
  var languages: [String]
  var types: [String]

  init() {
    categories = []
    languages = []
    types = []
  }
}
