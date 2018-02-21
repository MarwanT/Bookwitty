//
//  ProfileCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol ProfileCardViewModelDelegate: class {
  func resourceUpdated(viewModel: ProfileCardViewModel)
}

class ProfileCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: ProfileCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (name: String?, biography: String?, imageUrl: String?, following: Bool, followers: Int?, reported: Reported) {
    guard let resource = resource, let penName = resource as? PenName else {
      return (nil, nil, nil, false, nil, .not)
    }

    let name = penName.name
    let biography = penName.biography
    let imageUrl = penName.avatarUrl
    let following = resource.following
    let followers = resource.counts?.followers
    let reported: Reported = DataManager.shared.isReported(resource as? ModelResource)

    return (name: name, biography: biography, imageUrl: imageUrl, following: following, followers: followers, reported: reported)
  }
}
