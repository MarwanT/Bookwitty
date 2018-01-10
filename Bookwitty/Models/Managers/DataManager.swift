//
//  DataManager.swift
//  Bookwitty
//
//  Created by charles on 4/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class DataManager {

  enum Action {
    case wit
    case unwit
    case follow
    case unfollow
    case report
  }

  static let shared = DataManager()
  private init() {}

  fileprivate var pool: [String : ModelResource] = [:]
  fileprivate var reported: [String] = []

  //MARK: - Accessing Resources
  func fetchResource(with identifier: String) -> ModelResource? {
    return pool[identifier]
  }

  func fetchResources(with identifiers: [String]) -> [ModelResource] {
    return identifiers.flatMap(fetchResource(with:))
  }

  //MARK: - Update Resources
  private func poolUpdate(resource: ModelResource) {
    guard let identifier = resource.id else {
      return
    }

    if var newResource = resource as? ModelCommonProperties,
      let existingResource = pool[identifier] as? ModelCommonProperties {
      if newResource.penName == nil {
        newResource.penName = existingResource.penName
      }

      if !(newResource.counts?.isValid() ?? true) {
        newResource.counts = existingResource.counts
      }

      if newResource.contributors?.count ?? 0 <= existingResource.contributors?.count ?? 0 {
        newResource.contributors = existingResource.contributors
      }

      if newResource.tags?.count ?? 0 <= existingResource.tags?.count ?? 0 {
        newResource.tags = existingResource.tags
      }

      if let newBook = newResource as? Book, newBook.productFormats?.count ?? 0 == 0,
        let existingBook = existingResource as? Book {
        newBook.productFormats = existingBook.productFormats
        newBook.following = existingBook.following
      }
    }

    pool.updateValue(resource, forKey: identifier)
  }

  func update(resource: ModelResource) {
    poolUpdate(resource: resource)

    if let identifier = resource.id {
      let dictionary = [Notifications.Key.Update : [identifier]]
      notifyUpdate(resources: dictionary)
    }
  }

  func update(resources: [ModelResource]) {
    resources.forEach(self.poolUpdate(resource:))

    let identifiers = resources.flatMap({ $0.id })

    let dictionary = [Notifications.Key.Update : identifiers]
    notifyUpdate(resources: dictionary)
  }

  func updateResource(with identifier: String, after action: Action) {
    guard let resource = self.fetchResource(with: identifier) else {
      return
    }

    switch action {
    case .wit:
      wit(resource)
    case .unwit:
      unwit(resource)
    case .follow:
      follow(resource)
    case .unfollow:
      unfollow(resource)
    case .report:
      report(resource)
    }

    let dictionary = [Notifications.Key.Update : [identifier]]
    notifyUpdate(resources: dictionary)
  }

  private func notifyUpdate(resources: [String : [String]]) {
    NotificationCenter.default.post(name: Notifications.Name.UpdateResource, object: resources)
  }

  //MARK: - Reported Resource
  func isReported(_ resource: ModelResource?) -> Bool {
    guard let identifier = resource?.id else {
      return false
    }
    return reported.contains(identifier)
  }

  func deleteResource(with identifier: String) {
    guard let index = pool.index(forKey: identifier) else {
      return
    }

    pool.remove(at: index)
    let dictionary = [Notifications.Key.Delete : [identifier]]
    notifyUpdate(resources: dictionary)
  }

  //MARK: - Remove Resources
  //TODO: Will be discussed and implemented later
}


//MARK: - Update After Action Implementations
extension DataManager {
  fileprivate func wit(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.wit = true
  }

  fileprivate func unwit(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.wit = false
  }

  fileprivate func follow(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.isFollowing = true
  }

  fileprivate func unfollow(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.isFollowing = false
  }
}

//MARK: - Update After Action Implementations - Extra Actions
extension DataManager {
  fileprivate func report(_ resource: ModelResource) {
    guard let identifier = resource.id else {
      return
    }
    reported.append(identifier)
  }
}

//MARK: - Notifications
extension DataManager {
  struct Notifications {
    struct Name {
      static let UpdateResource = Notification.Name("DataManager.Notifications.Name.UpdateResource")
    }

    struct Key {
      static let Update = "Update"
      static let Delete = "Delete"
    }
  }
}
