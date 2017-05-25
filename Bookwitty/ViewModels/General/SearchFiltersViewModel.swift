//
//  SearchFiltersViewModel.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class SearchFiltersViewModel {
  var facet: Facet?

  func initialize(with facet: Facet) {
    self.facet = facet
  }
}
