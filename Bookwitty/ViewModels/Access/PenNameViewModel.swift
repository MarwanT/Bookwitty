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

  func penBiography() -> String {
    return penName?.biography ?? ""
  }

  func initializeWith(penName: PenName?, andUser user: User?) {
    self.penName = penName
    self.user = user
  }

  func updatePenNameIfNeeded(name: String?, biography: String?, avatarId: String?, completion: ((Bool)->())?) {
    guard let penName = penName, let identifier = penName.id else {
      completion?(false)
      return
    }

    if updateRequest != nil {
      updateRequest?.cancel()
    }

    updateRequest = PenNameAPI.updatePenName(identifier: identifier, name: name, biography: biography, avatarId: avatarId, avatarUrl: nil, facebookUrl: nil, tumblrUrl: nil, googlePlusUrl: nil, twitterUrl: nil, instagramUrl: nil, pinterestUrl: nil, youtubeUrl: nil, linkedinUrl: nil, wordpressUrl: nil, websiteUrl: nil) {
      (success: Bool, penName: PenName?, error: BookwittyAPIError?) in
      defer {
        completion?(success)
      }
      
      if let penName = penName {
        self.penName = penName
        if let index = self.user?.penNames?.index(where: { $0.id == penName.id }) {
          self.user?.penNames?[index] = penName
        }
      }
    }
  }
}
