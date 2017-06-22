//
//  PenNameListViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class PenNameListViewModel {
  private(set) var penNames: [PenName] = []

  func initialize(with penNames: [PenName]) {
    self.penNames = penNames
  }
}

//MARK: - ASCollectionDataSource helpers
extension PenNameListViewModel {
  private func penName(at item: Int) -> PenName? {
    guard item >= 0 && item < penNames.count else {
      return nil
    }

    return penNames[item]
  }
}
