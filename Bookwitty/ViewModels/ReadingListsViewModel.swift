//
//  ReadingListsViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class ReadingListsViewModel {
  fileprivate var dataArray: [ReadingList] = []

  func initialize(with lists: [ReadingList]) {
    dataArray.removeAll()
    dataArray += lists
  }
}

//MARK: - Collection Helpers
extension ReadingListsViewModel {
  func numberOfItems() -> Int {
    return dataArray.count
  }

  func readingList(at item: Int) -> ReadingList? {
    guard item >= 0 && item < dataArray.count else {
      return nil
    }

    return dataArray[item]
  }
}
