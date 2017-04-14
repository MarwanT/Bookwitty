//
//  DataManager.swift
//  Bookwitty
//
//  Created by charles on 4/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class DataManager {
  static let shared = DataManager()
  private init() {}

  fileprivate var pool: [String : ModelResource] = [:]

  //MARK: - Accessing Resources
  func fetchResource(with identifier: String) -> ModelResource? {
    return pool[identifier]
  }

  func fetchResources(with identifiers: [String]) -> [ModelResource] {
    return identifiers.flatMap(fetchResource(with:))
  }

  //MARK: - Update Resources
  @discardableResult
  func update(resource: ModelResource) {
    guard let identifier = resource.id else {
      return
    }
    pool.updateValue(resource, forKey: identifier)
  }

  //MARK: - Remove Resources
  //TODO: Will be discussed and implemented later
}
