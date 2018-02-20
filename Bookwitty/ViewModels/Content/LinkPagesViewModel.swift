//
//  LinkPagesViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class LinkPagesViewModel {
  var canLink: Bool = true
  fileprivate var pages: [ModelCommonProperties] = []
  fileprivate var selectedPages: [ModelCommonProperties] = []
  let filter: Filter = Filter()
  private(set) var contentIdentifier: String!
  
  var getSelectedPages: [ModelCommonProperties] {
    return self.selectedPages
  }
  
  var titlesForSelectedPages: [String] {
    return self.selectedPages.flatMap { $0.title }
  }
  
  init() {
    self.filter.types = [Topic.resourceType, Author.resourceType]
  }
  
  func initialize(with contentIdentifier: String, linkedPages: [ModelCommonProperties]) {
    self.contentIdentifier = contentIdentifier
    self.selectedPages = linkedPages
  }
  
  func select(_ page: ModelCommonProperties) {
    if !self.isSelected(page) {
      selectedPages.append(page)
    }
  }
  
  func unselect(_ page: ModelCommonProperties) {
    guard let index = self.selectedPages.index(where: { $0.id == page.id }) else {
      return
    }
    
    self.selectedPages.remove(at: index)
  }
  
  func hasSimilarTitle(_ title: String) -> Bool {
    return self.selectedPages.flatMap { $0.title }.contains(title)
  }
  
  func unselectPage(with title: String) -> ModelCommonProperties? {
    let unselectedPage = self.selectedPages.first { $0.title == title }
    self.selectedPages = self.selectedPages.filter { !($0.title == title) }
    return unselectedPage
  }
  
  func setPages(_ pages: [ModelCommonProperties]) {
    self.pages = pages
  }
  
  fileprivate func page(for row: Int) -> ModelCommonProperties? {
    guard row >= 0 && row < pages.count else {
      return nil
    }
    
    return pages[row]
  }
  
  func isSelected(_ page: ModelCommonProperties) -> Bool {
    return selectedPages.contains(where: { $0.id == page.id })
  }
}
// Mark: - TableView helper
extension LinkPagesViewModel {
  func numberOfItemsInSection(section: Int) -> Int {
    return pages.count
  }

  func values(for row: Int) -> (page: ModelCommonProperties?, linked: Bool) {
    guard let page = self.page(for: row) else {
      return (nil, false)
    }
    
    return (page, self.isSelected(page))
  }
}
