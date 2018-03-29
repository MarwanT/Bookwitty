//
//  TagCardViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation

protocol TagCardViewModelDelegate: class {
  func resourceUpdated(viewModel: TagCardViewModel)
}

class TagCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: TagCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (title: String?, following: Bool, followers: Int?, reported: Reported) {
    guard let resource = resource, let tag = resource as? Tag else {
      return (nil, false, nil, .not)
    }

    let name = tag.title
    let following = resource.following
    let followers = resource.counts?.followers
    let reported: Reported = DataManager.shared.isReported(resource as? ModelResource)

    return (name, following, followers, reported)
  }
}
