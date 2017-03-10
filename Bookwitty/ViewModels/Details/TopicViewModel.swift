//
//  TopicViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class TopicViewModel {

  enum CallbackCategory {
    case content
    case latest
    case editions
    case relatedBooks
    case followers
  }

  var callback: ((CallbackCategory) -> ())?

  var topic: Topic?
  var book: Book?

  fileprivate var latest: [ModelResource] = []
  fileprivate var editions: [Book] = []
  fileprivate var relatedBooks: [Book] = []
  fileprivate var followers: [PenName] = []

  func initialize(withTopic topic: Topic?) {
    self.topic = topic
    initiateContentCalls()
  }

  func initialize(withBook book: Book?) {
    self.book = book
    initiateContentCalls()
  }

  var identifier: String? {
    if let topic = topic {
      return topic.id
    }

    if let book = book {
      return book.id
    }

    return nil
  }

  private func initiateContentCalls() {
    if topic != nil {
      getTopicContent()
    }

    if book != nil {
      getBookContent()
      getEditions()
    }

    getLatest()
    getRelatedBooks()
    getFollowers()
  }


  func valuesForHeader() -> (title: String?, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    if topic != nil {
      return valuesForTopic()
    }

    if book != nil {
      return valuesForBook()
    }

    return (nil, nil, nil, stats: (nil, nil), contributors: (nil, nil))
  }

  private func valuesForTopic() -> (title: String?, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
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
    let contributorsImages: [String]? = topic.contributors?.flatMap({ $0.avatarUrl })

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)
    
    return (title: title, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
  }

  private func valuesForBook() -> (title: String?, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let book = book else {
      return (nil, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }

    let title  = book.title
    let thumbnail = book.thumbnailImageUrl
    let cover = book.coverImageUrl
    let counts = book.counts
    let followers = String(counting: counts.followers)
    let posts = String(counting: counts.posts)
    let contributors = String(counting: counts.contributors)
    let contributorsImages: [String]? = book.contributors?.flatMap({ $0.avatarUrl })

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)

    return (title: title, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
  }

  private func getTopicContent() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.content(of: identifier, include: ["contributors"]) {
      (success: Bool, topic: Topic?, error: BookwittyAPIError?) in
      if success {
        guard let topic = topic else {
          return
        }

        self.topic = topic
        self.callback?(.content)
      }
    }
  }

  private func getBookContent() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.content(of: identifier, include: ["contributors"]) {
      (success: Bool, topic: Topic?, error: BookwittyAPIError?) in
      if success {
        guard let topic = topic else {
          return
        }

        self.topic = topic
        self.callback?(.content)
      }
    }
  }
}

//MARK: - Latest
extension TopicViewModel {
  func numberOfLatest() -> Int {
    return latest.count
  }

  func latest(at item: Int) -> ModelResource? {
    guard item >= 0 && item < latest.count else {
      return nil
    }

    return latest[item]
  }

  func getLatest(loadMore: Bool = false) {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.posts(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, error: BookwittyAPIError?) in
      if success {
        if !loadMore {
          self.latest.removeAll()
        }
        self.latest += resources ?? []
        self.callback?(.latest)
      }
    }
  }
}

//MARK: - Editions
extension TopicViewModel {
  func numberOfEditions() -> Int {
    return editions.count
  }

  func edition(at item: Int) -> Book? {
    guard item >= 0 && item < editions.count else {
      return nil
    }

    return editions[item]
  }

  func getEditions() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.editions(contentIdentifier: identifier) {
      (success: Bool, resources: [ModelResource]?, error: BookwittyAPIError?) in
      if success {
        self.editions.removeAll()
        self.editions += (resources as? [Book]) ?? []
        self.callback?(.editions)
      }
    }
  }
}

//MARK: - Related Books
extension TopicViewModel {
  func numberOfRelatedBooks() -> Int {
    return relatedBooks.count
  }

  func relatedBook(at item: Int) -> Book? {
    guard item >= 0 && item < relatedBooks.count else {
      return nil
    }

    return relatedBooks[item]
  }

  func getRelatedBooks() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.posts(contentIdentifier: identifier, type: [Book.resourceType]) {
      (success: Bool, resources: [ModelResource]?, error: BookwittyAPIError?) in
      if success {
        self.relatedBooks.removeAll()
        let books = resources?.filter({ $0.registeredResourceType == Book.resourceType })
        self.relatedBooks += (books as? [Book]) ?? []
        self.callback?(.relatedBooks)
      }
    }
  }
}

//MARK: - Followers
extension TopicViewModel {
  func numberOfFollowers() -> Int {
    return followers.count
  }

  func follower(at item: Int) -> PenName? {
    guard item >= 0 && item < followers.count else {
      return nil
    }

    return followers[item]
  }

  func getFollowers() {
    guard let identifier = identifier else {
      return
    }

    _ = PenNameAPI.followers(contentIdentifier: identifier) {
      (success: Bool, penNames: [PenName]?, error: BookwittyAPIError?) in
      if success {
        self.followers.removeAll()
        self.followers += penNames ?? []
        self.callback?(.followers)
      }
    }
  }
}
