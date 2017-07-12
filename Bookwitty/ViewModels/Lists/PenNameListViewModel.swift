//
//  PenNameListViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class PenNameListViewModel {

  fileprivate var resource: ModelResource?
  fileprivate(set) var penNames: [PenName] = []

  fileprivate var nextPage: URL?

  func initialize(with penNames: [PenName]) {
    self.penNames = penNames
  }

  func initialize(with resource: ModelResource) {
    self.resource = resource
  }

  func penName(at item: Int) -> PenName? {
    guard item >= 0 && item < penNames.count else {
      return nil
    }

    return penNames[item]
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }
}

//MARK: - ASCollectionDataSource helpers
extension PenNameListViewModel {
  func numberOfPenNames() -> Int {
    return penNames.count
  }

  func values(at item: Int) -> (identifier: String?, penName: String?, biography: String?, imageUrl: String?, following: Bool, isMyPenName: Bool)? {
    guard let penName = penName(at: item) else {
      return nil
    }

    let mine = UserManager.shared.isMyDefault(penName: penName)
    return (penName.id, penName.name, penName.biography, penName.avatarUrl, penName.following, mine)
  }
}

//MARK: - Data Fetchers
extension PenNameListViewModel {
  func getVoters(completion: @escaping (_ success: Bool)->()) {
    guard let resource = resource, let id = resource.id else {
      completion(false)
      return
    }

    _ = GeneralAPI.votes(contentIdentifier: id) { (success: Bool, votes: [Vote]?, next: URL?, error: BookwittyAPIError?) in
      self.penNames = votes?.flatMap({ $0.penName }) ?? []
      self.nextPage = next
      completion(success)
    }
  }

  func getNextPage(completion: @escaping (_ success: Bool)->()) {
    guard let next = nextPage else {
      completion(false)
      return
    }

    _ = GeneralAPI.nextPage(nextPage: next) { (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      guard let votes = resources as? [Vote] else {
        completion(false)
        return
      }

      self.penNames += votes.flatMap({ $0.penName })
      self.nextPage = next
      completion(success)
    }
  }
}

//MARK: - Actions
extension PenNameListViewModel {
  func follow(at item: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName(at: item), let identifier = penName.id else {
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

  func unfollow(at item: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName(at: item), let identifier = penName.id else {
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
}
