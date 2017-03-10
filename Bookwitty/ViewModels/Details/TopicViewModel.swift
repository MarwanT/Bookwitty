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
  var author: Author?

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

  func initialize(withAuthor author: Author?) {
    self.author = author
    initiateContentCalls()
  }

  var identifier: String? {
    if let topic = topic {
      return topic.id
    }

    if let book = book {
      return book.id
    }

    if let author = author {
      return author.id
    }

    return nil
  }

  private func initiateContentCalls() {
    if topic != nil {
      getTopicContent()
    }

    if author != nil {
      getAuthorContent()
    }

    if book != nil {
      getBookContent()
      getEditions()
    }

    getLatest()
    getRelatedBooks()
    getFollowers()
  }


  func valuesForHeader() -> (title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    if topic != nil {
      return valuesForTopic()
    }

    if book != nil {
      return valuesForBook()
    }

    if author != nil {
      return valuesForAuthor()
    }

    return (nil, false, nil, nil, stats: (nil, nil), contributors: (nil, nil))
  }

  private func valuesForTopic() -> (title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let topic = topic else {
      return (nil, false, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }

    let title  = topic.title
    let following = topic.following
    let thumbnail = topic.thumbnailImageUrl
    let cover = topic.coverImageUrl
    let counts = topic.counts
    let followers = String(counting: counts.followers)
    let posts = String(counting: counts.posts)
    let contributors = String(counting: counts.contributors)
    let contributorsImages: [String]? = topic.contributors?.flatMap({ $0.avatarUrl })

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)

    return (title: title, following: following, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
  }

  private func valuesForBook() -> (title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let book = book else {
      return (nil, false, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }

    let title  = book.title
    let following = book.following
    let thumbnail = book.thumbnailImageUrl
    let cover = book.coverImageUrl
    let counts = book.counts
    let followers = String(counting: counts.followers)
    let posts = String(counting: counts.posts)
    let contributors = String(counting: counts.contributors)
    let contributorsImages: [String]? = book.contributors?.flatMap({ $0.avatarUrl })

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)

    return (title: title, following: following, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
  }

  private func valuesForAuthor() -> (title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let author = author else {
      return (nil, false, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }

    let title  = author.name
    let following = author.following
    let thumbnail = author.thumbnailImageUrl
    let cover = author.coverImageUrl
    let counts = author.counts
    let followers = String(counting: counts.followers)
    let posts = String(counting: counts.posts)
    let contributors = String(counting: counts.contributors)
    let contributorsImages: [String]? = author.contributors?.flatMap({ $0.avatarUrl })

    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)

    return (title: title, following: following, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
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
      (success: Bool, book: Book?, error: BookwittyAPIError?) in
      if success {
        guard let book = book else {
          return
        }

        self.book = book
        self.callback?(.content)
      }
    }
  }

  private func getAuthorContent() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.content(of: identifier, include: ["contributors"]) {
      (success: Bool, author: Author?, error: BookwittyAPIError?) in
      if success {
        guard let author = author else {
          return
        }

        self.author = author
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

//MARK: - Follow / Unfollow
extension TopicViewModel {

  func followContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }

    followRequest(identifier: identifier) { (success: Bool) in
      defer {
        completionBlock(success)
      }

      if success {
        if let topic = self.topic {
          topic.following = true
        }

        if let book = self.book {
          book.following = true
        }

        if let author = self.author {
          author.following = true
        }
      }
    }
  }

  func unfollowContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }

    unfollowRequest(identifier: identifier) { (success: Bool) in
      defer {
        completionBlock(success)
      }

      if success {
        if let topic = self.topic {
          topic.following = false
        }

        if let book = self.book {
          book.following = false
        }

        if let author = self.author {
          author.following = false
        }
      }
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }
}
