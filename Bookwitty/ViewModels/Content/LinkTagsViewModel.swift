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
  
  func append(_ tag: Tag) {
    if !selectedTags.contains(tag) {
      selectedTags.append(tag)
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
  
  func fetchedTag(withTitle title: String) -> Tag? {
    return fetchedTags.first(where: { $0.title == title })
  }
  
  func selectedTag(withTitle title: String) -> Tag? {
    return selectedTags.first(where: { $0.title == title })
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
  
  func addTagg(withTitle title: String, completion: ((_ success: Bool) -> Void)?) {
    let newTag = Tag()
    newTag.title = title
    let allTags = selectedTags + [newTag]
    replace(with: allTags, completion: completion)
  }
  
  func replace(with tags: [Tag], completion: ((_ success: Bool) -> Void)?) {
    self.selectedTags = tags
    //TODO: change .draft value below to a proper status value
    _ = TagAPI.replaceTags(for: contentIdentifier, with: tags.flatMap { $0.title }, status: .draft, completion: {
      [weak self] (success, post, error) in
      guard let strongSelf = self else { return }
      
      guard success, let post = post, let tags = post.tags else {
        completion?(false)
        return
      }
      //Previously we were setting the tags on success
      //After BMA-1683 we asked to consider the tag is linked
      strongSelf.selectedTags = tags
    })
  }
  
  func unLink(withTitle: String, completion: ((_ success: Bool) -> Void)?) {
    guard let tag = self.selectedTag(withTitle: withTitle), let tagID = tag.id else {
      completion?(false)
      return
    }
    
    selectedTags = selectedTags.filter { $0.id != tagID }
    _ = TagAPI.removeTag(for: contentIdentifier, with: tagID, completion: {
      (success, error) in
      defer {
        completion?(success)
      }
      
      guard success else {
        return
      }
    })
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
