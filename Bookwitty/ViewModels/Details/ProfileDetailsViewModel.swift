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
  var followers: [ModelResource] = []
  var following: [ModelResource] = []

  init(penName: PenName) {
    self.penName = penName
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
