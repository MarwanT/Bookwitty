//
//  PostsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

final class PostsViewModel {
  var viewControllerTitle: String? = nil
  
  var posts = [ModelResource]()
  fileprivate var loadingMode: DataLoadingMode? = nil
  
  var isLoadingNextPage: Bool = false
  var didReachLastPage: Bool = false
  var hasNextPage: Bool {
    return !didReachLastPage
  }
  var hasNoPosts: Bool {
    return posts.count == 0
  }
  
  var shouldShowBottomLoader = false
  fileprivate var shouldReloadPostsSections = false
  
  /// Given an array of resources, they will be considered as
  /// the items of the first page
  func initialize(title: String?, resources: [ModelResource]?, loadingMode: DataLoadingMode?) {
    viewControllerTitle = title
    self.loadingMode = loadingMode
    if let resources = resources {
      self.posts = resources
    }
  }
  
  /// Currently this method resets 'should reload' flags when called
  func sectionsNeedsReloading() -> [PostsViewController.Section] {
    var sections:[PostsViewController.Section] = []
    if shouldReloadPostsSections {
      shouldReloadPostsSections = false
      sections += [.posts]
    }
    sections += [.activityIndicator]
    return sections
  }
  
  func resourceForIndexPath(indexPath: IndexPath) -> Resource? {
    guard let section = PostsViewController.Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .posts:
      return posts[indexPath.item]
    default:
      return nil
    }
  }
}

// MARK: - APIs
extension PostsViewModel {
  fileprivate func loadPostsForURL(url: URL, completion: @escaping (_ success: Bool, _ nextPage: URL?) -> Void) {
    _ = GeneralAPI.nextPage(nextPage: url, completion: {
      (success, resources, nextPageURL, error) in
      defer {
        completion(success, nextPageURL)
      }
      
      guard success, let resources = resources else {
        return
      }
      self.shouldReloadPostsSections = resources.count > 0
      DataManager.shared.update(resources: resources)
      self.posts.append(contentsOf: resources)
    })
  }
}

// MARK: - Load more
extension PostsViewModel {
  /// This method also loads the first page
  func loadNextPage(completion: @escaping (_ success: Bool) -> Void) {
    guard let loadingMode = loadingMode else {
      completion(false)
      return
    }
    
    switch loadingMode {
    case .server(let absoluteURL):
      guard let url = absoluteURL else {
        self.didReachLastPage = true
        self.isLoadingNextPage = false
        completion(false)
        return
      }
      
      isLoadingNextPage = true
      
      loadPostsForURL(url: url, completion: {
        (success, nextPageURL) in
        self.isLoadingNextPage = false
        self.loadingMode = .server(absoluteURL: nextPageURL)
        completion(success)
      })
    case .local(let paginator):
      guard let nextPageIds = paginator.nextPageIds(), nextPageIds.count > 0 else {
        self.didReachLastPage = true
        self.isLoadingNextPage = false
        completion(false)
        return
      }
      
      isLoadingNextPage = false
      
      loadResourcesForIds(identifiers: nextPageIds, completion: {
        (success) in
        self.isLoadingNextPage = false
        completion(success)
      })
    }
  }
  
  fileprivate func loadResourcesForIds(identifiers: [String], completion: @escaping (_ success: Bool) -> Void) {
    _ = UserAPI.batch(identifiers: identifiers, completion: {
      (success, resources, error) in
      defer {
        completion(success)
      }
      
      guard success, let resources = resources else {
        return
      }
      self.shouldReloadPostsSections = resources.count > 0
      DataManager.shared.update(resources: resources)
      self.posts.append(contentsOf: resources)
    })
  }
  
}

// MARK: - Collection view data source and delegate
extension PostsViewModel {
  var numberOfSections: Int {
    return PostsViewController.Section.numberOfSections
  }
  
  func numberOfItemsForSection(for section: Int) -> Int {
    guard let section = PostsViewController.Section(rawValue: section) else {
      return 0
    }
    switch section {
    case .posts:
      return posts.count
    case .activityIndicator:
      return shouldShowBottomLoader ? 1 : 0
    }
  }
  
  func nodeForItem(at indexPath: IndexPath) -> BaseCardPostNode? {
    var node: BaseCardPostNode? = nil
    guard let section = PostsViewController.Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .posts:
      let resource = posts[indexPath.item]
      node = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
      node?.baseViewModel?.resource = resource as? ModelCommonProperties
    case .activityIndicator:
      return nil
    }
    return node
  }
  
  func shouldSelectItem(at indexPath: IndexPath) -> Bool {
    guard let section = PostsViewController.Section(rawValue: indexPath.section) else {
      return false
    }
    
    switch section {
    case .posts:
      return true
    case .activityIndicator:
      return false
    }
  }
}

// MARK: - Handle Reading Lists Images
extension PostsViewModel {
  func loadReadingListImages(at indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = posts[indexPath.item] as? ReadingList else {
      completionBlock(nil)
      return
    }
    
    var ids: [String] = []
    if let list = readingList.postsRelations {
      for item in list {
        ids.append(item.id)
      }
    }
    
    if ids.count > 0 {
      let limitToMaximumIds = Array(ids.prefix(maxNumberOfImages))
      loadReadingListItems(readingListIds: limitToMaximumIds, completionBlock: completionBlock)
    } else {
      completionBlock(nil)
    }
  }
  
  private func loadReadingListItems(readingListIds: [String], completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    _ = UserAPI.batch(identifiers: readingListIds) { (success, resources, error) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if success {
        var images: [String] = []
        resources?.forEach({ (resource) in
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

// MARK: - Declarations
extension PostsViewModel {
  enum DataLoadingMode {
    case server(absoluteURL: URL?)
    case local(paginator: Paginator)
  }
}

// MARK: - Posts Actions
extension PostsViewModel {
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    let resource = posts[indexPath.item]
    guard let contentId = resource.id else {
        completionBlock(false)
        return
    }

    _ = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    let resource = posts[indexPath.item]
    guard let contentId = resource.id else {
      completionBlock(false)
      return
    }

    _ = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .unwit)
      }
      completionBlock(success)
    })
  }

  func sharingContent(indexPath: IndexPath) -> [String]? {
    let resource = posts[indexPath.item]
    guard let commonProperties = resource as? ModelCommonProperties else {
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
extension PostsViewModel {
  func follow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    let resource = posts[indexPath.item]
    guard let resourceId = resource.id else {
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

  func unfollow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    let resource = posts[indexPath.item]
    guard let resourceId = resource.id else {
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
