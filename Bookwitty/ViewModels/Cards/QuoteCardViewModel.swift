//
//  QuoteCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol QuoteCardViewModelDelegate: class {
  func resourceUpdated(viewModel: QuoteCardViewModel)
}

class QuoteCardViewModel {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: QuoteCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }
}
