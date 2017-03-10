//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class PenNameViewModel {
  private(set) var penName: PenName?
  private var user: User?

  private var updateRequest: Cancellable? = nil

  func penDisplayName() -> String {
    return penName?.name ?? ""
  }

  func initializeWith(penName: PenName?, andUser user: User?) {
    self.penName = penName
    self.user = user
  }

  func updatePenNameIfNeeded(name: String?, biography: String?, completion: ((Bool)->())?) {
    var successful = false
    defer {
      completion?(successful)
    }

    guard let penName = penName else {
      return
    }

    guard let identifier = penName.id else {
      return
    }

    //no needed update if nothing changed
    if name == penName.name && penName.biography == biography {
      successful = true
      return
    }

    if updateRequest != nil {
      updateRequest?.cancel()
    }

    updateRequest = PenNameAPI.updatePenName(identifier: identifier, name: name, biography: biography, avatarUrl: nil, facebookUrl: nil, tumblrUrl: nil, googlePlusUrl: nil, twitterUrl: nil, instagramUrl: nil, pinterestUrl: nil, youtubeUrl: nil, linkedinUrl: nil, wordpressUrl: nil, websiteUrl: nil) {
      (success: Bool, penName: PenName?, error: BookwittyAPIError?) in
      successful = success
      if let penName = penName {
        self.penName = penName
        if let index = self.user?.penNames?.index(where: { $0.id == penName.id }) {
          self.user?.penNames?[index] = penName
        }
      }
    }
  }
}
