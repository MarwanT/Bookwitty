//
//  Paginator.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class Paginator {
  private var ids: [String]
  private var pageSize: Int
  private var startIndex: Int

  init(ids: [String] ,pageSize: Int = 10, startPage: Int = 0) {
    self.ids = ids
    self.pageSize = pageSize
    self.startIndex = min((startPage * pageSize), ids.endIndex)
  }

  func hasMorePages() -> Bool {
    return startIndex < ids.endIndex
  }

  func nextPageIds() -> [String]? {
    guard startIndex < ids.endIndex else {
      return nil
    }
    let endIndex = min((startIndex + pageSize), ids.endIndex)
    let nextRangeIds: ArraySlice<String> = ids[startIndex..<endIndex]

    startIndex = endIndex

    return Array(nextRangeIds)
  }

  func currentIdentifiers() -> [String]? {
    guard startIndex < ids.endIndex else {
      return nil
    }
    let endIndex = min((startIndex + pageSize), ids.endIndex)
    let nextRangeIds: ArraySlice<String> = ids[startIndex..<endIndex]
    return Array(nextRangeIds)
  }

  func incrementPage() {
    startIndex += pageSize
  }
}
