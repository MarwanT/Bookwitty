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

  func values() -> (name: String?, biography: String?, imageUrl: String?, following: Bool, followers: Int?) {
    guard let resource = resource else {
      return (nil, nil, nil, false, nil)
    }

    let name = resource.title
    let biography = resource.shortDescription
    let imageUrl = resource.coverImageUrl
    let following = resource.following
    let followers = resource.counts?.followers

    return (name: name, biography: biography, imageUrl: imageUrl, following: following, followers: followers)
  }
}
