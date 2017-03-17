//
//  ProfileDetailsViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class ProfileDetailsViewModel {
  let penName: PenName

  var latestData: [ModelResource] = []
  var followers: [PenName] = []
  var following: [ModelResource] = []
  var nextPage: URL?
  
  init(penName: PenName) {
    self.penName = penName
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

    _ = PenNameAPI.penNameContent(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.nextPage = nextUrl
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

    _ = PenNameAPI.penNameFollowers(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.nextPage = nextUrl
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

    _ = PenNameAPI.penNameFollowing(identifier: id) { (success, resources, nextUrl, error) in
      defer {
        self.nextPage = nextUrl
        completion(success, error)
      }
      self.following.removeAll(keepingCapacity: false)
      self.following += resources ?? []
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
