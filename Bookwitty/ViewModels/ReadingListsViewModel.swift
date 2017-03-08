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
