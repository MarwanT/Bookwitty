//
//  OnBoardingViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class OnBoardingViewModel {
  var cancellableRequest: Cancellable?
  var data:  [String : OnBoardingCollectionItem]?

  func loadOnBoardingData(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = CuratedCollectionAPI.onBoarding { (success, curatedCollection, error) in
      guard let sections = curatedCollection?.sections else {
        completionBlock(false)
        return
      }

      if let onBoardingList = sections.curatedCollectionOnBoardList {
        self.data = onBoardingList
      }

      completionBlock(false)
    }
  }

  func numberOfOnBoardingTitleSections() -> Int {
    return data != nil ? 1 : 0
  }

  func numberOfItems() -> Int {
    guard let data = data else {
      return 0
    }
    return data.count
  }

  func onBoardingCellNodeTitle(index: Int) -> String {
    guard let data = data else {
      return ""
    }
    let dataArray = Array(data.keys)
    guard (index >= 0 && index < dataArray.count) else {
      return ""
    }

    let item = Array(data.keys)[index]
    return item
  }

  func curatedOnBoardingData(index: Int) -> [String : [CuratedCollectionItem]]? {
    guard let data = data else {
      return nil
    }
    let dataArray = Array(data.values)
    guard (index >= 0 && index < dataArray.count) else {
      return nil
    }

    let item: OnBoardingCollectionItem = dataArray[index]
    var itemData: [String : [CuratedCollectionItem]] = [:]
    itemData["topic"] = []
    if let featured = item.featured {
      itemData["topic"]? += featured
    }
    if let wittyIds = item.wittyIds {
      itemData["topic"]? += wittyIds
    }

    return itemData
  }
}
