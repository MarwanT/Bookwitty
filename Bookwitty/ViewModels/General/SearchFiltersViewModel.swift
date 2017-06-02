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

  var candidateFilter: Filter?

  var sections: [Facet.Options] = []
  var expandedSections: [Int] = []

  func initialize(with facet: Facet, and filter: Filter) {
    self.facet = facet
    self.filter = filter

    self.candidateFilter = Filter()
    self.candidateFilter?.categories = self.filter?.categories ?? []
    self.candidateFilter?.languages = self.filter?.languages ?? []
    self.candidateFilter?.types = self.filter?.types ?? []

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
      return Strings.categories()
    case .languages:
      return Strings.languages()
    case .types:
      return Strings.types()
    }
  }

  fileprivate func subtitle(for section: Int) -> String? {
    guard let option = facetOption(at: section) else {
      return nil
    }

    switch option {
    case .categories:
      let localized = facet?.categories?.filter({ candidateFilter?.categories.contains($0.key ?? "") ?? false }).flatMap({ $0.value }) ?? []
      return localized.joined(separator: ", ")
    case .languages:
      let localized = candidateFilter?.languages.flatMap({ Locale.application.localizedString(forLanguageCode: $0) }) ?? []
      return localized.joined(separator: ", ")
    case .types:
      let localized = candidateFilter?.types.flatMap({ $0.localizedName }) ?? []
      return localized.joined(separator: ", ")
    }
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

  fileprivate func toggleCategory(at row: Int) {
    guard let filter = candidateFilter, let cat = category(at: row), let key = cat.key else {
      return
    }

    if filter.categories.contains(key) {
      filter.categories.removeAll()
    } else {
      filter.categories.removeAll()
      filter.categories.append(key)
    }
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

  fileprivate func toggleLanguage(at row: Int) {
    let lang = language(at: row)
    guard let filter = candidateFilter, let code = lang.code else {
      return
    }

    if filter.languages.contains(code) {
      filter.languages.removeAll()
    } else {
      filter.languages.removeAll()
      filter.languages.append(code)
    }
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

  fileprivate func toggleType(at row: Int) {
    let typ = type(at: row)
    guard let filter = candidateFilter, let resourceType = typ.resourceType else {
      return
    }

    if filter.types.contains(resourceType) {
      filter.types.removeAll()
    } else {
      filter.types.removeAll()
      filter.types.append(resourceType)
    }
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

  func values(for section: Int) -> (title: String?, subtitle: String?, mode: SearchFilterTableViewSectionHeaderView.Mode) {
    let title = self.title(for: section)
    let subtitle = self.subtitle(for: section)
    let mode: SearchFilterTableViewSectionHeaderView.Mode = expandedSections.contains(section) ? .expanded : .collapsed
    return (title, subtitle, mode)
  }

  func values(forRowAt indexPath: IndexPath) -> (title: String?, selected: Bool) {
    var title: String? = nil
    var selected: Bool = false

    guard let option = facetOption(at: indexPath.section) else {
      return (nil, false)
    }

    switch option {
    case .categories:
      let cat = category(at: indexPath.row)
      title = cat?.value
      selected = candidateFilter?.categories.contains(cat?.key ?? "") ?? false
    case .languages:
      let lang = language(at: indexPath.row)
      title = lang.localized
      selected = candidateFilter?.languages.contains(lang.code ?? "") ?? false
    case .types:
      let typ = type(at: indexPath.row)
      title = typ.localized
      selected = candidateFilter?.types.contains(typ.resourceType ?? "") ?? false
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

  func toggleRow(at indexPath: IndexPath) {
    guard let option = facetOption(at: indexPath.section) else {
      return
    }

    switch option {
    case .categories:
      toggleCategory(at: indexPath.row)
    case .languages:
      toggleLanguage(at: indexPath.row)
    case .types:
      toggleType(at: indexPath.row)
    }
  }
}
