//
//  TopicViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

final class TopicViewModel {

  enum CallbackCategory {
    case content
    case latest
    case editions
    case relatedBooks
    case followers
  }

  var callback: ((CallbackCategory) -> ())?
  
  var resource: ModelCommonProperties?

  fileprivate var latest: [String] = []
  fileprivate var latestNextUrl: URL? = nil

  fileprivate var editions: [String] = []
  fileprivate var editionsNextUrl: URL? = nil

  fileprivate var relatedBooks: [String] = []
  fileprivate var relatedBooksNextUrl: URL? = nil

  fileprivate var followers: [String] = []
  fileprivate var followersNextUrl: URL? = nil
  
  func initialize(with resource: ModelCommonProperties?) {
    self.resource = resource
    initiateContentCalls()
  }

  var identifier: String? {
    return resource?.id
  }
  
  var externalySharedContent: [Any]? {
    var canonicalURL: URL? = nil
    var title: String? = nil
    var sharedContent = [Any]()
    
    canonicalURL = resource?.canonicalURL
    title = resourceTitle
    
    if let canonicalURL = canonicalURL {
      sharedContent.append(canonicalURL)
    }
    if let title = title {
      sharedContent.append(title)
    }
    
    return sharedContent.count > 0 ? sharedContent : nil
  }

  var resourceType: ResourceType? {
    return resource?.registeredResourceType
  }
  
  var resourceTitle: String? {
    guard let resource = resource else {
      return nil
    }
    
    switch resource {
    case let author as Author:
      return author.name
    default:
      return resource.title
    }
  }
  
  var contributorsImages: [String]? {
    guard let resource = resource else {
      return nil
    }
    
    switch resource {
    case let author as Author:
      return author.contributors?.flatMap({ $0.avatarUrl })
    case let book as Book:
      return book.contributors?.flatMap({ $0.avatarUrl })
    case let topic as Topic:
      return topic.contributors?.flatMap({ $0.avatarUrl })
    default: return nil
    }
  }
  
  var resourceCover: String? {
    guard let resourceType = resourceType else {
      return nil
    }
    
    switch resourceType {
    case Topic.resourceType:
      return resource?.coverImageUrl
    default: return nil
    }
  }
  
  var resourceThumbnail: String? {
    guard let resourceType = resourceType else {
      return nil
    }
    
    switch resourceType {
    case Author.resourceType, Book.resourceType:
      return resource?.thumbnailImageUrl
    default: return nil
    }
  }

  private func initiateContentCalls() {
    if let resourceType = resourceType {
      switch resourceType {
      case Topic.resourceType:
        getTopicContent()
      case Author.resourceType:
        getAuthorContent()
      case Book.resourceType:
        getBookContent()
        getEditions()
      default: break
      }
    }
    
    getLatest()
    getRelatedBooks()
    getFollowers()
  }

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func valuesForHeader() -> (identifier: String?, title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?)) {
    guard let resource = resource else {
      return (nil, nil, false, nil, nil, stats: (nil, nil), contributors: (nil, nil))
    }
    
    let identifier = resource.id
    let title  = resourceTitle
    let following = resource.following
    let thumbnail = self.resourceThumbnail
    let cover = self.resourceCover
    let counts = resource.counts
    let followers = String(counting: counts?.followers)
    let posts = String(counting: counts?.posts)
    let contributors = String(counting: counts?.contributors)
    let contributorsImages: [String]? = self.contributorsImages
    
    let stats: (String?, String?) = (followers, posts)
    let contributorsValues: (String?, [String]?) = (contributors, contributorsImages)

    return (identifier: identifier, title: title, following: following, thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats, contributors: contributorsValues)
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

        DataManager.shared.update(resource: topic)
        self.resource = topic
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

        DataManager.shared.update(resource: book)
        self.resource = book
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

        DataManager.shared.update(resource: author)
        self.resource = author
        self.callback?(.content)
      }
    }
  }
  
  func updateResourceIfNeeded() {
    guard let resourceId = self.resource?.id, let resource = DataManager.shared.fetchResource(with: resourceId) as? ModelCommonProperties else {
      return
    }
    self.resource = resource
  }
}

//MARK: - Latest
extension TopicViewModel {
  var hasNextLatest: Bool {
    return self.latestNextUrl != nil
  }

  func numberOfLatest() -> Int {
    return latest.count
  }

  func latest(at item: Int) -> ModelResource? {
    guard item >= 0 && item < latest.count else {
      return nil
    }
    
    let latestResourceId = latest[item]
    guard let resource = DataManager.shared.fetchResource(with: latestResourceId) else {
      return nil
    }

    return resource
  }
  
  func valuesForLatest(at item: Int) -> (identifier: String?, resourceType: ResourceType?)? {
    guard let latestResource = latest(at: item) else {
      return nil
    }
    
    return (latestResource.id, latestResource.registeredResourceType)
  }

  func getLatest() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      if success {
        let resourcesIds: [String] = resources?.flatMap({ $0.id }) ?? []
        _ = self.handleLatest(results: resourcesIds, next: next, reset: true)
        self.callback?(.latest)
        DataManager.shared.update(resources: resources ?? [])
      }
    }
  }

  fileprivate func handleLatest(results: [String]?, next: URL?, reset: Bool = false) -> [Int]? {
    guard let results = results else {
      return nil
    }

    if reset {
      self.latest.removeAll()
    }

    let lastIndex = self.latest.endIndex
    self.latest += results
    self.latestNextUrl = next
    return Array(lastIndex..<self.latest.endIndex)
  }
}

//MARK: - Editions
extension TopicViewModel {
  var hasNextEditions: Bool {
    return self.editionsNextUrl != nil
  }

  func numberOfEditions() -> Int {
    return editions.count
  }

  func edition(at item: Int) -> Book? {
    guard item >= 0 && item < editions.count else {
      return nil
    }
    
    let editionId = editions[item]
    guard let book = DataManager.shared.fetchResource(with: editionId) as? Book else {
      return nil
    }
    
    return book
  }
  
  func valuesForEdition(at item: Int) -> (identifier: String?, title: String?, author: String?, format: String?, price: String?, imageUrl: String?)? {
    guard let book = edition(at: item) else {
      return nil
    }
    
    return (book.id, book.title, book.productDetails?.author, book.productDetails?.productFormat, book.preferredPrice?.formattedValue, book.thumbnailImageUrl)
  }

  func getEditions() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.editions(contentIdentifier: identifier) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      if success {
        let resourcesIds: [String] = resources?.flatMap({ $0.id }) ?? []
        _ = self.handleEdition(results: resourcesIds, next: next, reset: true)
        self.callback?(.editions)
        DataManager.shared.update(resources: resources ?? [])
      }
    }
  }

  fileprivate func handleEdition(results: [String]?, next: URL?, reset: Bool = false) -> [Int]? {
    guard let results = results, results.count > 0 else {
      return nil
    }

    if reset {
      self.editions.removeAll()
    }

    let lastIndex = self.editions.endIndex
    self.editions += results
    self.editionsNextUrl = next
    return Array(lastIndex..<self.editions.endIndex)
  }
}

//MARK: - Related Books
extension TopicViewModel {
  var hasNextRelatedBooks: Bool {
    return self.relatedBooksNextUrl != nil
  }

  func numberOfRelatedBooks() -> Int {
    return relatedBooks.count
  }

  func relatedBook(at item: Int) -> Book? {
    guard item >= 0 && item < relatedBooks.count else {
      return nil
    }
    
    let relatedBooksId = relatedBooks[item]
    guard let book = DataManager.shared.fetchResource(with: relatedBooksId) as? Book else {
      return nil
    }
    
    return book
  }
  
  func valuesForRelatedBook(at item: Int) -> (identifier: String?, title: String?, author: String?, format: String?, price: String?, imageUrl: String?)? {
    guard let book = relatedBook(at: item) else {
      return nil
    }
    
    return (book.id, book.title, book.productDetails?.author, book.productDetails?.productFormat, book.preferredPrice?.formattedValue, book.thumbnailImageUrl)
  }

  func getRelatedBooks() {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: [Book.resourceType]) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      if success {
        self.relatedBooks.removeAll()
        let books = resources?.filter({ $0.registeredResourceType == Book.resourceType })
        let resourcesIds: [String] = books?.flatMap({ $0.id }) ?? []
        _ = self.handleRelatedBooks(results: resourcesIds, next: next, reset: true)
        self.callback?(.relatedBooks)
        DataManager.shared.update(resources: resources ?? [])
      }
    }
  }

  fileprivate func handleRelatedBooks(results: [String]?, next: URL?, reset: Bool = false) -> [Int]? {
    guard let results = results, results.count > 0 else {
      return nil
    }

    if reset {
      self.relatedBooks.removeAll()
    }
    let lastIndex = self.relatedBooks.endIndex
    self.relatedBooks += results
    self.relatedBooksNextUrl = next
    return Array(lastIndex..<self.relatedBooks.endIndex)
  }
}

//MARK: - Followers
extension TopicViewModel {
  func isMyPenName(_ penName: PenName?) -> Bool {
    guard let penName = penName else {
      return false
    }
    return UserManager.shared.isMy(penName: penName)
  }

  var hasNextFollowers: Bool {
    return self.followersNextUrl != nil
  }

  func numberOfFollowers() -> Int {
    return followers.count
  }

  func follower(at item: Int) -> PenName? {
    guard item >= 0 && item < followers.count else {
      return nil
    }
    
    let followersId = followers[item]
    guard let follower = DataManager.shared.fetchResource(with: followersId) as? PenName else {
      return nil
    }
    
    return follower
  }
  
  func valuesForFollower(at item: Int) -> (identifier: String?, penName: String?, biography: String?, imageUrl: String?, following: Bool, isMyPenName: Bool)? {
    guard let penName = follower(at: item) else {
      return nil
    }
    
    return (penName.id, penName.name, penName.biography, penName.avatarUrl, penName.following, isMyPenName(penName))
  }

  func getFollowers() {
    guard let identifier = identifier else {
      return
    }

    _ = PenNameAPI.followers(contentIdentifier: identifier) {
      (success: Bool, penNames: [PenName]?, next: URL?, error: BookwittyAPIError?) in
      if success {
        let followersIds: [String] = penNames?.flatMap({ $0.id }) ?? []
        _ = self.handleFollowers(results: followersIds, next: next, reset: true)
        self.callback?(.followers)
        DataManager.shared.update(resources: penNames ?? [])
      }
    }
  }

  fileprivate func handleFollowers(results: [String]?, next: URL?, reset: Bool = false) -> [Int]? {
    guard let results = results else {
      return nil
    }

    if reset {
      self.followers.removeAll()
    }
    let lastIndex = self.followers.endIndex
    self.followers += results
    self.followersNextUrl = next
    return Array(lastIndex..<self.followers.endIndex)
  }
}

//MARK: - Next Page
extension TopicViewModel {
  func loadNext(for category: CallbackCategory, closure: ((_ success: Bool, _ indices: [Int]?, _ category: CallbackCategory)->())?) {
    var url: URL? = nil
    switch category {
    case .latest:
      url = self.latestNextUrl
    case .relatedBooks:
      url = self.relatedBooksNextUrl
    case .editions:
      url = self.editionsNextUrl
    case .followers:
      url = self.followersNextUrl
    default:
      url = nil
    }

    guard let next = url else {
      return
    }

    _ = GeneralAPI.nextPage(nextPage: next) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in

      var successful: Bool = false
      var indices: [Int]? = nil

      defer {
        closure?(successful, indices, category)
        DataManager.shared.update(resources: resources ?? [])
      }

      successful = resources != nil
      
      let resourcesIdentifiers: [String]? = resources?.flatMap({ $0.id })

      switch category {
      case .latest:
        indices = self.handleLatest(results: resourcesIdentifiers, next: next)
      case .editions:
        indices = self.handleEdition(results: resourcesIdentifiers, next: next)
      case .relatedBooks:
        indices = self.handleRelatedBooks(results: resourcesIdentifiers, next: next)
      case .followers:
        indices = self.handleFollowers(results: resourcesIdentifiers, next: next)
      case .content:
        break
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
    }
  }

  func followPenName(at item: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = follower(at: item), let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
      }
      penName.following = true
    }
  }

  func unfollowPenName(at item: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = follower(at: item), let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
      }
      penName.following = false
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
      }
    }
  }
}
