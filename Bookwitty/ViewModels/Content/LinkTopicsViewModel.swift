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
  fileprivate var topics: [Topic] = []
  fileprivate var selectedTopics: [Topic] = []
  let filter: Filter = Filter()
  private(set) var contentIdentifier: String!
  
  var getSelectedTopics: [Topic] {
    return self.selectedTopics
  }
  
  var titlesForSelectedTopics: [String] {
    return self.selectedTopics.flatMap { $0.title }
  }
  
  init() {
    self.filter.types = [Topic.resourceType]
  }
  
  func initialize(with contentIdentifier: String, linkedTopics: [Topic]) {
    self.contentIdentifier = contentIdentifier
    self.selectedTopics = linkedTopics
  }
  
  func select(_ topic: Topic) {
    if !self.isSelected(topic) {
      selectedTopics.append(topic)
    }
  }
  
  func unselect(_ topic: Topic) {
    guard let index = self.selectedTopics.index(where: { $0.id == topic.id }) else {
      return
    }
    
    self.selectedTopics.remove(at: index)
  }
  
  func hasSimilarTitle(_ title: String) -> Bool {
    return self.selectedTopics.flatMap { $0.title }.contains(title)
  }
  
  func unselectTopic(with title: String) -> Topic? {
    let unselectedTopic = self.selectedTopics.first { $0.title == title }
    self.selectedTopics = self.selectedTopics.filter { !($0.title == title) }
    return unselectedTopic
  }
  
  func setTopics(_ topics: [Topic]) {
    self.topics = topics
  }
  
  fileprivate func topic(for row: Int) -> Topic? {
    guard row >= 0 && row < topics.count else {
      return nil
    }
    
    return topics[row]
  }
  
  func isSelected(_ topic:Topic) -> Bool {
    return selectedTopics.contains(where: { $0.id == topic.id })
  }
}
// Mark: - TableView helper
extension LinkTopicsViewModel {
  func numberOfItemsInSection(section: Int) -> Int {
    return topics.count
  }
  func values(for row: Int) -> (topic: Topic?, linked: Bool) {
    guard let topic = self.topic(for: row) else {
      return (nil, false)
    }
    
    return (topic, self.isSelected(topic))
  }
}
