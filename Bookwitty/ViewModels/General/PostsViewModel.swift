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
  
  var posts = [ModelResource]()
  fileprivate var loadingMode: DataLoadingMode? = nil
  
  var isLoadingNextPage: Bool = false
  var didReachLastPage: Bool = false
  var hasNextPage: Bool {
    return !didReachLastPage
  }
  var hasNoPosts: Bool {
    return posts.count > 0
  }
  
  fileprivate var shouldReloadPostsSections = false
  
  /// Given an array of resources, they will be considered as
  /// the items of the first page
  func initialize(resources: [ModelResource]?, loadingMode: DataLoadingMode?) {
    self.loadingMode = loadingMode
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
    }
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
      return 0
    case .activityIndicator:
      return 0
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
      node = CardFactory.shared.createCardFor(resource: resource)
    case .activityIndicator:
      return nil
    }
    return node
  }
}

// MARK: - Declarations
extension PostsViewModel {
  enum DataLoadingMode {
    case server(absoluteURL: URL?)
  }
}
