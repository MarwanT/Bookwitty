//
//  OnBoardingViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

typealias CellNodeDataItemModel = (id: String?, shortDescription: String?, longDescription: String?, imageUrl: String?)

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

    let key = Strings.topics_to_follow()
    let item: OnBoardingCollectionItem = dataArray[index]
    var itemData: [String : [CuratedCollectionItem]] = [:]
    itemData[key] = []
    if let featured = item.featured {
      itemData[key]? += featured
    }
    if let wittyIds = item.wittyIds {
      itemData[key]? += wittyIds
    }

    return itemData
  }

  func loadOnBoardingCellNodeData(indexPath: IndexPath, completionBlock: @escaping (_ indexPath: IndexPath, _ success: Bool, _ dictionary: [String : [CellNodeDataItemModel]]?) -> ()) -> Cancellable? {
    let index = indexPath.row
    guard let items: [String : [CuratedCollectionItem]] = curatedOnBoardingData(index: index) else {
      completionBlock(indexPath, false, nil)
      return nil
    }
    let values: [CuratedCollectionItem] = items.flatMap { (item: (key: String, value: [CuratedCollectionItem])) -> [CuratedCollectionItem] in
      return item.value
    }
    let itemIds: [String] = values.flatMap { (item) -> String? in
      return item.wittyId
    }

    return UserAPI.batch(identifiers: itemIds) { (success, resources, error) in
      var dictionary: [String : [CellNodeDataItemModel]] = [:]
      defer {
        completionBlock(indexPath, success, dictionary)
      }
      guard let resources = resources else {
        return
      }
      //init dictionary
      for resource in resources {
        if let topic = resource as? Topic {
          let model: CellNodeDataItemModel = (topic.id, topic.title, topic.shortDescription, topic.thumbnailImageUrl)
          if let id = topic.id,
            let key = self.getRelatedKey(for: id, from: items) {
            if dictionary[key] == nil {
              dictionary[key] = []
            }
            dictionary[key]? = [model]
          }
        }
      }
    }
  }

  func getRelatedKey(for id: String, from items: [String : [CuratedCollectionItem]]) -> String? {
    let filteredDictionary = items.filter({ (dictionaryItem: (key: String, value: [CuratedCollectionItem])) -> Bool in
      return dictionaryItem.value.filter({ (curatedItem) -> Bool in
        return curatedItem.wittyId == id
      }).count >= 1
    })
    guard filteredDictionary.count > 0 else {
      return nil
    }
    return filteredDictionary[0].key
  }

  func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }

  func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }
}
