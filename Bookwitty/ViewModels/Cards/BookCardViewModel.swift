//
//  BookCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol BookCardViewModelDelegate: class {
  func resourceUpdated(viewModel: BookCardViewModel)
}

class BookCardViewModel {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: BookCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }
}
