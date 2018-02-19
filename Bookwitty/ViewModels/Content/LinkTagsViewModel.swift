//
//  LinkTagsViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class LinkTagsViewModel {
  var canLink: Bool = true
  fileprivate var fetchedTags: [Tag] = []
  var selectedTags: [Tag] = []
  let filter: Filter = Filter()
  private(set) var contentIdentifier: String!
  var hasTags: Bool {
    return fetchedTags.count > 0
  }
  init() {
    self.filter.types = [Tag.resourceType]
  }
  
  func initialize(with contentIdentifier: String, linkedTags: [Tag]) {
    self.contentIdentifier = contentIdentifier
    self.selectedTags = linkedTags
  }
  
  func tag(with title: String) -> Tag? {
    return self.selectedTags.filter { $0.title == title }.first
  }
  
  func append(_ tag: Tag) {
    if !selectedTags.contains(tag) {
      selectedTags.append(tag)
    }
  }
  
  func removeTag(with title: String) {
    if let index = selectedTags.index(where: { $0 == self.tag(with: title) }) {
      selectedTags.remove(at: index)
    }
  }
  
  func resetTags() {
    self.fetchedTags = []
  }
  
  func set(_ tags:[Tag]) {
    self.fetchedTags = tags
  }
  
  func getFetchedTag(at index:Int) -> Tag {
    return fetchedTags[index]
  }
  
  func hasTag(with title: String) -> Bool {
    return fetchedTags.filter { $0.title == title }.count > 0
  }
}

// Mark: - Data Helpers
extension LinkTagsViewModel {
  func autocomplete(with text: String?, completion: @escaping (_ success: Bool) -> Void) {
    guard let text = text, text.count > 0 else {
      completion(false)
      return
    }
    
    //Perform request
    self.filter.query = text
    _ = SearchAPI.autocomplete(filter: filter, page: nil) {
      (success, tags, _, _, error) in
      guard success, let tags = tags as? [Tag] else {
        self.resetTags()
        completion(false)
        return
      }
      
      self.set(tags)
      completion(true)
    }
  }
}

// Mark: - TableView helper
extension LinkTagsViewModel {
  func numberOfItemsInSection(section: Int) -> Int {
    return fetchedTags.count
  }
  
  func values(forRowAt indexPath: IndexPath) -> String? {
    guard fetchedTags.count > indexPath.row else { return nil }
    let resourceId = getFetchedTag(at: indexPath.row)
    return resourceId.title
  }
}
