//
//  TopicViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class TopicViewModel {
  var topic: Topic?

  fileprivate var latest: [ModelResource] = []
  fileprivate var editions: [Book] = []
  fileprivate var relatedBooks: [Book] = []
  fileprivate var followers: [PenName] = []

  func initialize(with topic: Topic?) {
    self.topic = topic
    initiateContentCalls()
  }

  private func initiateContentCalls() {

  }

  func valuesForTopic() -> (title: String?, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let topic = topic else {
      return (nil, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }

    let title  = topic.title
    let thumbnail = topic.thumbnailImageUrl
    let cover = topic.coverImageUrl
    let counts = topic.counts
    let followers = String(counting: counts.followers)
    let posts = String(counting: counts.posts)
    let contributors = String(counting: counts.contributors)

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, nil)
    
    return (title: title, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
  }
}
