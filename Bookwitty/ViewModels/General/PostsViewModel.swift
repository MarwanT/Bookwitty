//
//  PostsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PostsViewModel {
  
  var posts = [ModelResource]()
  fileprivate var loadingMode: DataLoadingMode? = nil
  
  /// Given an array of resources, they will be considered as
  /// the items of the first page
  func initialize(resources: [ModelResource]?, loadingMode: DataLoadingMode?) {
    self.loadingMode = loadingMode
  }
}

// MARK: - Declarations
extension PostsViewModel {
  enum DataLoadingMode {
    case server(absoluteURL: URL?)
  }
}
