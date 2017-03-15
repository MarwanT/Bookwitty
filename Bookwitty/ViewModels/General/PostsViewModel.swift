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
  fileprivate var shouldReloadPostsSections = false
  
  /// Given an array of resources, they will be considered as
  /// the items of the first page
  func initialize(resources: [ModelResource]?, loadingMode: DataLoadingMode?) {
    self.loadingMode = loadingMode
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

// MARK: - Declarations
extension PostsViewModel {
  enum DataLoadingMode {
    case server(absoluteURL: URL?)
  }
}
