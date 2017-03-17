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
  let penName: PenName

  var latestData: [ModelResource] = []
  var followers: [PenName] = []
  var following: [ModelResource] = []
  var latestNextPage: URL?
  var followersNextPage: URL?
  var followingNextPage: URL?
  var cancellableRequest: Cancellable?
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
}

// MARK: - API requests
extension ProfileDetailsViewModel {
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
      self.latestData.removeAll(keepingCapacity: false)
      self.latestData += resources ?? []
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
      self.followers.removeAll(keepingCapacity: false)
      self.followers += resources ?? []
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
      self.following.removeAll(keepingCapacity: false)
      self.following += resources ?? []
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
      if let resources = resources, success {
        switch segment {
        case .followers:
          self.followers += resources.flatMap({ $0 as? PenName })
        case .following:
          self.following += resources
        case .latest:
          self.latestData += resources
        default: break
        }
        self.setNextPage(segment: segment, url: nextPage)
      }
      self.cancellableRequest = nil
      completionBlock(success)
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
    case .latest: return latestData
    case .followers: return followers
    case .following: return following
    default: return nil
    }
  }

  func itemForSegment(segment: ProfileDetailsViewController.Segment, index: Int) -> ModelResource? {
    switch segment {
    case .latest: return latestData[index]
    case .followers: return followers[index]
    case .following: return following[index]
    default: return nil
    }
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
