//
//  SearchFiltersViewModel.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class SearchFiltersViewModel {
  var facet: Facet?
  var filter: Filter?

  var sections: [Facet.Options] = []
  var expandedSections: [Int] = []

  func initialize(with facet: Facet, and filter: Filter) {
    self.facet = facet
    self.filter = filter
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

  //Row Helpers
  fileprivate func category(at row: Int) -> Category? {
    guard let categories = facet?.categories, categories.count > 0 else {
      return nil
    }

    guard row >= 0 && row < categories.count else {
      return nil
    }

    return categories[row]
  }

  fileprivate func language(at row: Int) -> (code: String?, localized: String?) {
    guard let languages = facet?.languages, languages.count > 0 else {
      return (nil, nil)
    }

    guard row >= 0 && row < languages.count else {
      return (nil, nil)
    }

    let languageCode = languages[row]
    let localized = Locale.application.localizedString(forLanguageCode: languageCode)
    return (languageCode, localized)
  }

  fileprivate func type(at row: Int) -> (resourceType: String?, localized: String?) {
    guard let types = facet?.types, types.count > 0 else {
      return (nil, nil)
    }

    guard row >= 0 && row < types.count else {
      return (nil, nil)
    }

    let resourceType = types[row] as ResourceType
    return (resourceType, resourceType.localizedName)
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

    guard expandedSections.contains(section) else {
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

  func values(forRowAt indexPath: IndexPath) -> (title: String?, selected: Bool) {
    var title: String? = nil
    var selected: Bool = false

    guard let option = facetOption(at: indexPath.section) else {
      return (nil, false)
    }

    switch option {
    case .categories:
      title = category(at: indexPath.row)?.value
    case .languages:
      title = language(at: indexPath.row).localized
    case .types:
      title = type(at: indexPath.row).localized
    }

    return (title, selected)
  }

  func toggleSection(_ section: Int) {
    if let index = expandedSections.index(of: section) {
      expandedSections.remove(at: index)
    } else {
      expandedSections.append(section)
    }
  }
}
