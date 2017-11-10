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
  fileprivate var topics: [ModelCommonProperties] = []
  fileprivate var selectedTopics: [ModelCommonProperties] = []
  let filter: Filter = Filter()
  private(set) var contentIdentifier: String!
  
  var getSelectedTopics: [ModelCommonProperties] {
    return self.selectedTopics
  }
  
  var titlesForSelectedTopics: [String] {
    return self.selectedTopics.flatMap { $0.title }
  }
  
  init() {
    self.filter.types = [Topic.resourceType]
  }
  
  func initialize(with contentIdentifier: String, linkedTopics: [ModelCommonProperties]) {
    self.contentIdentifier = contentIdentifier
    self.selectedTopics = linkedTopics
  }
  
  func select(_ topic: ModelCommonProperties) {
    if !self.isSelected(topic) {
      selectedTopics.append(topic)
    }
  }
  
  func unselect(_ topic: ModelCommonProperties) {
    guard let index = self.selectedTopics.index(where: { $0.id == topic.id }) else {
      return
    }
    
    self.selectedTopics.remove(at: index)
  }
  
  func hasSimilarTitle(_ title: String) -> Bool {
    return self.selectedTopics.flatMap { $0.title }.contains(title)
  }
  
  func unselectTopic(with title: String) -> ModelCommonProperties? {
    let unselectedTopic = self.selectedTopics.first { $0.title == title }
    self.selectedTopics = self.selectedTopics.filter { !($0.title == title) }
    return unselectedTopic
  }
  
  func setTopics(_ topics: [ModelCommonProperties]) {
    self.topics = topics
  }
  
  fileprivate func topic(for row: Int) -> ModelCommonProperties? {
    guard row >= 0 && row < topics.count else {
      return nil
    }
    
    return topics[row]
  }
  
  func isSelected(_ topic: ModelCommonProperties) -> Bool {
    return selectedTopics.contains(where: { $0.id == topic.id })
  }
}
// Mark: - TableView helper
extension LinkPagesViewModel {
  func numberOfItemsInSection(section: Int) -> Int {
    return topics.count
  }

  func values(for row: Int) -> (topic: ModelCommonProperties?, linked: Bool) {
    guard let topic = self.topic(for: row) else {
      return (nil, false)
    }
    
    return (topic, self.isSelected(topic))
  }
}
