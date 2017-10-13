//
//  LinkTopicsViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class LinkTopicsViewModel {
  var canLink: Bool = true
  var topics: [Topic] = []
  var selectedTopics: [Topic] = []
  let filter: Filter = Filter()
  
  init() {
    self.filter.types = [Topic.resourceType]
  }
  
  func append(_ topic: Topic) {
    if !self.has(topic) {
      selectedTopics.append(topic)
    }
  }
  func remove(_ topic: Topic) {
    if let id = topic.id {
      self.selectedTopics = self.selectedTopics.filter { $0.id != id }
    }
  }
  
  func has(_ topic: Topic) -> Bool {
    if let id = topic.id {
      return selectedTopics.flatMap { $0.id }.contains(id)
    } else {
      return false
    }
  }
}
// Mark: - TableView helper
extension LinkTopicsViewModel {
  func numberOfItemsInSection(section: Int) -> Int {
    return topics.count
  }
  func values(forRowAt indexPath: IndexPath) -> String? {
    guard topics.count > indexPath.row else { return nil }
    let resourceId = topics[indexPath.row]
    return resourceId.title
  }
}
