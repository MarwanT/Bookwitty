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
    case initialize
  }

  var callback: ((CallbackCategory) -> ())?
  
  var resource: ModelCommonProperties? {
    didSet {
      if oldValue == nil {
        self.callback?(.initialize)
      }
    }
  }

  fileprivate var latest: [String] = []
  fileprivate var latestNextUrl: URL? = nil
  fileprivate var latestStatefulNodeStates: (StatefulNode.Mode, StatefulNode.Category, MisfortuneNode.Mode) = (.none, .none, .none)

  fileprivate var editions: [String] = []
  fileprivate var editionsNextUrl: URL? = nil
  fileprivate var editionsStatefulNodeStates: (StatefulNode.Mode, StatefulNode.Category, MisfortuneNode.Mode) = (.none, .none, .none)

  fileprivate var relatedBooks: [String] = []
  fileprivate var relatedBooksNextUrl: URL? = nil
  fileprivate var relatedBooksStatefulNodeStates: (StatefulNode.Mode, StatefulNode.Category, MisfortuneNode.Mode) = (.none, .none, .none)

  fileprivate var followers: [String] = []
  fileprivate var followersNextUrl: URL? = nil
  fileprivate var followersStatefulNodeStates: (StatefulNode.Mode, StatefulNode.Category, MisfortuneNode.Mode) = (.none, .none, .none)

  var bookRegistry: BookTypeRegistry = BookTypeRegistry()

  func initialize(with resource: ModelCommonProperties?) {
    self.resource = resource
    initiateContentCalls()
  }

  func reload() {
    guard let _ = resource else {
      return
    }
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
    
    if let title = title {
      sharedContent.append(title)
    }
    
    if let canonicalURL = canonicalURL {
      sharedContent.append(canonicalURL)
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
      default: break
      }
    }
  }

  func loadData(for category: TopicViewController.Category, completion: @escaping (Bool, TopicViewController.Category) -> ()) {
    switch category {
    case .editions:
      if numberOfEditions() == 0 {
        getEditions(category: category, completion: completion)
      } else {
        completion(true, category)
      }
    case .latest:
      if numberOfLatest() == 0 {
        getLatest(category: category, completion: completion)
      } else {
        completion(true, category)
      }
    case .relatedBooks:
      if numberOfRelatedBooks() == 0 {
        getRelatedBooks(category: category, completion: completion)
      } else {
        completion(true, category)
      }
    case .followers:
      if numberOfFollowers() == 0 {
        getFollowers(category: category, completion: completion)
      } else {
        completion(true, category)
      }
    default:
      completion(false, category)
    }
  }

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func valuesForHeader() -> (identifier: String?, title: String?, following: Bool, thumbnailImageUrl: String?, coverImageUrl: String?, stats: (followers: String?, posts: String?), contributors: (count: String?, imageUrls: [String]?), description: String?, isMyPenName: Bool) {
    guard let resource = resource else {
      return (nil, nil, false, nil, nil, stats: (nil, nil),
              contributors: (nil, nil), nil, false)
    }
    
    let identifier = resource.id
    let title  = resourceTitle
    let description  = resource.shortDescription
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
    let isMine = isMyPenName(resource.penName)

    return (identifier: identifier, title: title, following: following,
            thumbnailImageUrl: thumbnail, coverImageUrl: cover, stats: stats,
            contributors: contributorsValues, description: description,
            isMyPenName: isMine)
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

//MARK: - Stateful Mode
extension TopicViewModel {
  func getStatefulStates(for category: TopicViewController.Category) ->
    (mode: StatefulNode.Mode, category: StatefulNode.Category, state: MisfortuneNode.Mode) {
    switch category {
    case .editions:
      return editionsStatefulNodeStates
    case .followers:
      return followersStatefulNodeStates
    case .latest:
      return latestStatefulNodeStates
    case .relatedBooks:
      return relatedBooksStatefulNodeStates
    default:
      return (.none, .none, .none)
    }
  }

  fileprivate func getStatefulNodeMode() -> StatefulNode.Mode {
    guard let resource = resource else {
      return .none
    }

    switch resource.registeredResourceType {
    case Author.resourceType:
      return .author
    case Book.resourceType:
      return .book
    case Topic.resourceType:
      return .topic
    default:
      return .none
    }
  }

  fileprivate func updateStatefulNodeStates(for category: TopicViewController.Category, mode: MisfortuneNode.Mode) {
    let statefulMode = getStatefulNodeMode()

    switch category {
    case .editions:
      editionsStatefulNodeStates = (statefulMode, StatefulNode.Category.editions, mode)
    case .followers:
      followersStatefulNodeStates = (statefulMode, StatefulNode.Category.followers, mode)
    case .latest:
      latestStatefulNodeStates = (statefulMode, StatefulNode.Category.latest, mode)
    case .relatedBooks:
      relatedBooksStatefulNodeStates = (statefulMode, StatefulNode.Category.relatedBooks, mode)
    default:
      return
    }
  }

  fileprivate func updateMisfortuneMode(category: TopicViewController.Category, isEmpty: Bool?, error: BookwittyAPIError?) {
    let misfortuneNodeMode: MisfortuneNode.Mode

    if let isReachable = AppManager.shared.reachability?.isReachable, !isReachable {
      misfortuneNodeMode = MisfortuneNode.Mode.noInternet
    } else if let _ = error {
      misfortuneNodeMode = MisfortuneNode.Mode.somethingWrong
    } else {
      misfortuneNodeMode = (isEmpty ?? false) ? MisfortuneNode.Mode.empty : .none
    }

    updateStatefulNodeStates(for: category, mode: misfortuneNodeMode)
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

  func getLatest(category: TopicViewController.Category, completion: @escaping (Bool, TopicViewController.Category) -> ()) {
    guard let identifier = identifier else {
      completion(false, category)
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success, category)
      }

      self.updateMisfortuneMode(category: category, isEmpty: resources?.isEmpty, error: error)

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.topicLatest)

        let resourcesIds: [String] = resources.flatMap({ $0.id })
        _ = self.handleLatest(results: resourcesIds, next: next, reset: true)
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

  func getEditions(category: TopicViewController.Category, completion: @escaping (Bool, TopicViewController.Category) -> ()) {
    guard let identifier = identifier else {
      completion(false, category)
      return
    }

    _ = ContentAPI.editions(contentIdentifier: identifier, formats: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success, category)
      }

      self.updateMisfortuneMode(category: category, isEmpty: resources?.isEmpty, error: error)

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        let resourcesIds: [String] = resources.flatMap({ $0.id })
        _ = self.handleEdition(results: resourcesIds, next: next, reset: true)
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

  func getRelatedBooks(category: TopicViewController.Category, completion: @escaping (Bool, TopicViewController.Category) -> ()) {
    guard let identifier = identifier else {
      completion(false, category)
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: [Book.resourceType]) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success, category)
      }

      self.updateMisfortuneMode(category: category, isEmpty: resources?.isEmpty, error: error)

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.relatedBooks.removeAll()
        let books = resources.filter({ $0.registeredResourceType == Book.resourceType })
        let resourcesIds: [String] = books.flatMap({ $0.id })
        _ = self.handleRelatedBooks(results: resourcesIds, next: next, reset: true)
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

  func getFollowers(category: TopicViewController.Category, completion: @escaping (Bool, TopicViewController.Category) -> ()) {
    guard let identifier = identifier else {
      completion(false, category)
      return
    }

    _ = PenNameAPI.followers(contentIdentifier: identifier) {
      (success: Bool, penNames: [PenName]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success, category)
      }

      self.updateMisfortuneMode(category: category, isEmpty: penNames?.isEmpty, error: error)

      if let penNames = penNames, success {
        DataManager.shared.update(resources: penNames)
        let followersIds: [String] = penNames.flatMap({ $0.id })
        _ = self.handleFollowers(results: followersIds, next: next, reset: true)
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
      }

      successful = resources != nil

      DataManager.shared.update(resources: resources ?? [])
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
      case .content, .initialize:
        break
      }
    }
  }

  func sharingContent(resource: Resource?) -> [String]? {
    guard let commonProperties = resource as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}

//MARK: - wit / unwit
extension TopicViewModel {
  func witContent(contentId: String?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let id = contentId else {
      completionBlock(false)
      return
    }

    _ = NewsfeedAPI.wit(contentId: id, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: id, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(contentId: String?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let id = contentId else {
      completionBlock(false)
      return
    }

    _ = NewsfeedAPI.unwit(contentId: id, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: id, after: DataManager.Action.unwit)
      }
      completionBlock(success)
    })
  }
}

//MARK: - Follow / Unfollow
extension TopicViewModel {
  func follow(resource: Resource?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resource, let id = resource.id else {
      completionBlock(false)
      return
    }

    if let penName = resource as? PenName {
      _ = GeneralAPI.followPenName(identifer: id) { (success, error) in
        defer {
          completionBlock(success)
        }
        if success {
          DataManager.shared.updateResource(with: id, after: DataManager.Action.follow)
          penName.following = true
        }
      }
    } else {
      followRequest(identifier: id) { (success: Bool) in
        defer {
          completionBlock(success)
        }
      }
    }
  }

  func unfollow(resource: Resource?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resource, let id = resource.id else {
      completionBlock(false)
      return
    }

    if let penName = resource as? PenName {
      _ = GeneralAPI.unfollowPenName(identifer: id) { (success, error) in
        defer {
          completionBlock(success)
        }
        if success {
          DataManager.shared.updateResource(with: id, after: DataManager.Action.follow)
          penName.following = false
        }
      }
    } else {
      unfollowRequest(identifier: id) { (success: Bool) in
        defer {
          completionBlock(success)
        }
      }
    }
  }

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

// MARK: - Handle Reading Lists Images
extension TopicViewModel {
  func loadReadingListImages(at latestItemIndex: Int, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = latest(at: latestItemIndex) as? ReadingList,
      let identifier = readingList.id else {
        completionBlock(nil)
        return
    }
    
    let pageSize: String = String(maxNumberOfImages)
    let page: (number: String?, size: String?) = (nil, pageSize)
    _ = GeneralAPI.postsContent(contentIdentifier: identifier, page: page) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if let resources = resources, success {
        var images: [String] = []
        resources.forEach({ (resource) in
          if let res = resource as? ModelCommonProperties {
            if let imageUrl = res.thumbnailImageUrl {
              images.append(imageUrl)
            }
          }
        })
        imageCollection = images
      }
    }
  }
}

// MARK: - Handle Deleting Resource
extension TopicViewModel {
  func deleteResource(with identifier: String) {
    if let index = latest.index(where: { $0 == identifier }) {
      latest.remove(at: index)
    }

    if let index = editions.index(where: { $0 == identifier }) {
      editions.remove(at: index)
    }

    if let index = relatedBooks.index(where: { $0 == identifier }) {
      relatedBooks.remove(at: index)
    }

    if let index = followers.index(where: { $0 == identifier }) {
      followers.remove(at: index)
    }
  }
}
