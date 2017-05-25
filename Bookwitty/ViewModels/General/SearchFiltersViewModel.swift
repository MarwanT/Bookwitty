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

  fileprivate func title(for section: Int) -> String? {
    guard let option = facetOption(at: section) else {
      return nil
    }

    switch option {
    case .categories:
      return "Categories" //TODO: Localize
    case .languages:
      return "Languages" //TODO: Localize
    case .types:
      return "Types" //TODO: Localize
    }
  }

  fileprivate func subtitle(for section: Int) -> String? {
    return nil
  }
}

//Facet Table View Mirorring
extension SearchFiltersViewModel {
  func numberOfSections() -> Int {
    return sections.count
  }

  func numberOfRows(in section: Int) -> Int {
    guard let option = facetOption(at: section) else {
      return 0
    }

    switch option {
    case .categories:
      return facet?.categories?.count ?? 0
    case .languages:
      return facet?.languages?.count ?? 0
    case .types:
      return facet?.types?.count ?? 0
    }
  }

  func values(for section: Int) -> (title: String?, subtitle: String?) {
    let title = self.title(for: section)
    let subtitle = self.subtitle(for: section)
    return (title, subtitle)
  }
}
