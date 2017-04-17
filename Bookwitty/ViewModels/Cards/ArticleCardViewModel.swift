//
//  ArticleCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol ArticleCardViewModelDelegate: class {
  func resourceUpdated(viewModel: ArticleCardViewModel)
}

class ArticleCardViewModel {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: ArticleCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }
}
