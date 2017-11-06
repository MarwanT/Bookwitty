//
//  ProfileDetailsViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class ProfileDetailsViewModel {
  var penName: PenName

  var latestData: [String] = []
  var followers: [String] = []
  var following: [String] = []
  var latestNextPage: URL?
  var followersNextPage: URL?
  var followingNextPage: URL?
  var cancellableRequest: Cancellable?
  var bookRegistry: BookTypeRegistry = BookTypeRegistry()

  init(penName: PenName) {
    self.penName = penName
  }

  func cancelActiveRequest() {
    guard let cancellableRequest = cancellableRequest else {
      return
    }
    if !cancellableRequest.isCancelled {
      cancellableRequest.cancel()
    }
  }

  func isMyPenName() -> Bool {
    return UserManager.shared.isMy(penName: penName)
  }

  func resourcesFor(array: [String]?) -> [ModelResource]? {
    guard let array = array else {
      return nil
    }
    return DataManager.shared.fetchResources(with: array)
  }

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath], segment: ProfileDetailsViewController.Segment) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(indexPath: indexPath, segment: segment) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return resourcesIdentifiers.contains(identifier)
    })
  }

  func deleteResource(with identifier: String) {
    if let index = latestData.index(where: { $0 == identifier }) {
      latestData.remove(at: index)
    }
  }
}

// MARK: - API requests
extension ProfileDetailsViewModel {
  func loadPenName(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penNameId = penName.id else {
      completionBlock(false)
      return
    }
    _ = PenNameAPI.penNameDetails(identifier: penNameId, completionBlock: { (success, penName, error) in
      defer {
        completionBlock(success)
      }
      if let penName = penName, success {
         DataManager.shared.update(resource: penName)
        self.penName = penName
      }
    })
  }

  func data(for segment: ProfileDetailsViewController.Segment, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    switch segment {
    case .latest:
      if latestData.count > 0 {
        completion(true, nil)
        return
      } else {
        fetchData(for: segment, completion: completion)
      }
    case .followers:
      if followers.count > 0 {
        completion(true, nil)
        return
      } else {
        fetchData(for: segment, completion: completion)
      }
    case .following:
      if following.count > 0 {
        completion(true, nil)
        return
      } else {
        fetchData(for: segment, completion: completion)
      }
    default: return
    }
  }

  func fetchData(for segment: ProfileDetailsViewController.Segment, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    switch segment {
    case .latest:
      fetchContent(completion: completion)
    case .followers:
      fetchFollowers(completion: completion)
    case .following:
      fetchFollowing(completion: completion)
    default: return
    }
  }

  func fetchContent(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let id = penName.id else {
      completion(false, nil)
      return
    }

    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = PenNameAPI.penNameContent(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.latestNextPage = nextUrl
        completion(success, error)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.profileLatest)

        self.latestData.removeAll(keepingCapacity: false)
        self.latestData += resources.flatMap({ $0.id })
      }
    }
  }

  func fetchFollowers(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let id = penName.id else {
      completion(false, nil)
      return
    }

    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = PenNameAPI.penNameFollowers(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.followersNextPage = nextUrl
        completion(success, error)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.followers.removeAll(keepingCapacity: false)
        self.followers += (resources).flatMap({ $0.id })
      }
    }
  }

  func fetchFollowing(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let id = penName.id else {
      completion(false, nil)
      return
    }

    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = PenNameAPI.penNameFollowing(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.followingNextPage = nextUrl
        completion(success, error)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.profileFollowing)

        self.following.removeAll(keepingCapacity: false)
        self.following += resources.flatMap({ $0.id })
      }

    }
  }
}

// Mark: - Load More
extension ProfileDetailsViewModel {
  func loadNextPage(for segment: ProfileDetailsViewController.Segment, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage(segment: segment) else {
      completionBlock(false)
      return
    }
    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = GeneralAPI.nextPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      defer {
        self.cancellableRequest = nil
        completionBlock(success)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        switch segment {
        case .followers:
          self.followers += resources.flatMap({ $0.id })
        case .following:
          self.following += resources.flatMap({ $0.id })
        case .latest:
          self.latestData += resources.flatMap({ $0.id })
        default: break
        }
        self.setNextPage(segment: segment, url: nextPage)
      }
    }
  }

  func hasNextPage(segment: ProfileDetailsViewController.Segment) -> Bool {
    return (nextPage(segment: segment) != nil)
  }

  func nextPage(segment: ProfileDetailsViewController.Segment) -> URL? {
    switch segment {
    case .latest: return latestNextPage
    case .followers: return followersNextPage
    case .following: return followingNextPage
    default: return nil
    }
  }

  private func setNextPage(segment: ProfileDetailsViewController.Segment, url: URL?) {
    switch segment {
    case .latest:
      latestNextPage = url
    case .followers:
      followersNextPage = url
    case .following:
      followingNextPage = url
    default: return
    }
  }
}

// Mark: - Segment helper
extension ProfileDetailsViewModel {
  func countForSegment(segment: ProfileDetailsViewController.Segment) -> Int {
    switch segment {
    case .latest: return latestData.count
    case .followers: return followers.count
    case .following: return following.count
    default: return 0
    }
  }

  func dataForSegment(segment: ProfileDetailsViewController.Segment) -> [ModelResource]? {
    switch segment {
    case .latest: return resourcesFor(array: latestData)
    case .followers: return resourcesFor(array: followers)
    case .following: return resourcesFor(array: following)
    default: return nil
    }
  }

  func itemForSegment(segment: ProfileDetailsViewController.Segment, index: Int) -> ModelResource? {
    switch segment {
    case .latest: return resourceFor(id: latestData[index])
    case .followers: return resourceFor(id: followers[index])
    case .following: return resourceFor(id: following[index])
    default: return nil
    }
  }

  func isMyPenName(_ penName: PenName) -> Bool {
    return UserManager.shared.isMy(penName: penName)
  }
}

// Mark: - Collection helper
extension ProfileDetailsViewModel {
  func numberOfSections() -> Int {
    return ProfileDetailsViewController.Section.numberOfSections
  }

  func numberOfItemsInSection(section: Int, segment: ProfileDetailsViewController.Segment) -> Int {
    return ProfileDetailsViewController.Section.cells.rawValue == section ? countForSegment(segment: segment) : 1
  }

  func resourceForIndex(indexPath: IndexPath, segment: ProfileDetailsViewController.Segment) -> ModelResource? {
    guard countForSegment(segment: segment) > indexPath.row else { return nil }
    let resource = itemForSegment(segment: segment, index: indexPath.row)
    return resource
  }
}

// Mark: - Reading List
extension ProfileDetailsViewModel {
  func loadReadingListImages(segment: ProfileDetailsViewController.Segment, atIndexPath indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = resourceForIndex(indexPath: indexPath, segment: segment) as? ReadingList,
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


// MARK: - Posts Actions
extension ProfileDetailsViewModel {
  func witContent(segment: ProfileDetailsViewController.Segment, indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath, segment: segment),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(segment: ProfileDetailsViewController.Segment, indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath, segment: segment),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .unwit)
      }
      completionBlock(success)
    })
  }

  func sharingContent(segment: ProfileDetailsViewController.Segment, indexPath: IndexPath) -> [String]? {
    guard let resource = resourceForIndex(indexPath: indexPath, segment: segment),
      let commonProperties = resource as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}

// MARK: - PenName Follow/Unfollow
extension ProfileDetailsViewModel {
  func follow(segment: ProfileDetailsViewController.Segment, indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath, segment: segment),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      followPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      followRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  func unfollow(segment: ProfileDetailsViewController.Segment, indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath, segment: segment),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      unfollowPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      unfollowRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: .follow)
        penName.following = true
      }
    }
  }

  func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: .unfollow)
        penName.following = false
      }
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: .follow)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: .unfollow)
      }
    }
  }
}
