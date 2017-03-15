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

// MARK: - Declarations
extension PostsViewModel {
  enum DataLoadingMode {
    case server(absoluteURL: URL?)
  }
}
