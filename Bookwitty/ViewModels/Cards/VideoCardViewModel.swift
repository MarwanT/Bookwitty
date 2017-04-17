//
//  VideoCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol VideoCardViewModelDelegate: class {
  func resourceUpdated(viewModel: VideoCardViewModel)
}

class VideoCardViewModel {

  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: VideoCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }
}
