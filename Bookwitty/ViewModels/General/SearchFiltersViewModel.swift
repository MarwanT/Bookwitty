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

  var sections: [Facet.Options] = []

  func initialize(with facet: Facet) {
    self.facet = facet
    fillSections()
  }

  fileprivate func fillSections() {
    guard let facet = self.facet else {
      return
    }

    if facet.categories != nil {
      sections.append(Facet.Options.categories)
    }

    if facet.languages != nil {
      sections.append(Facet.Options.languages)
    }

    if facet.types != nil {
      sections.append(Facet.Options.types)
    }
  }

  //Section Helpers
  fileprivate func facetOption(at section: Int) -> Facet.Options? {
    guard section >= 0 && section < sections.count else {
      return nil
    }

    return sections[section]
  }
}
