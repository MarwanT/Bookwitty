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
    case dim
    case undim
    case follow
    case unfollow
  }

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
  func update(resource: ModelResource) {
    guard let identifier = resource.id else {
      return
    }
    
    pool.updateValue(resource, forKey: identifier)
  }

  func update(resources: [ModelResource]) {
    resources.forEach(self.update(resource:))
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
    case .dim:
      dim(resource)
    case .undim:
      undim(resource)
    case .follow:
      follow(resource)
    case .unfollow:
      unfollow(resource)
    }
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

  fileprivate func dim(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.dim = true
  }

  fileprivate func undim(_ resource: ModelResource) {
    var actionableRes = resource as? ModelCommonActions
    actionableRes?.dim = false
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

//MARK: - Notifications
extension DataManager {
  struct Notifications {
    struct Name {
      static let UpdateResource = Notification.Name("DataManager.Notifications.Name.UpdateResource")
    }
  }
}
