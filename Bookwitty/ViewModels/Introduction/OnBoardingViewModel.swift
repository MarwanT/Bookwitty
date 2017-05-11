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

typealias CellNodeDataItemModel = (id: String?, shortDescription: String?, longDescription: String?, imageUrl: String?, following: Bool?, resourceType: String)

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

  func topicsToFollowSection(for index: Int) -> [String : [CuratedCollectionItem]]? {
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

  func penNamesOnBoardingData(index: Int) -> [String : [String]]? {
    guard let data = data else {
      return nil
    }
    let dataArray = Array(data.values)
    guard (index >= 0 && index < dataArray.count) else {
      return nil
    }

    let key = Strings.pen_names_to_follow()
    let item: OnBoardingCollectionItem = dataArray[index]
    var itemData: [String : [String]] = [:]
    itemData[key] = []
    if let penNames = item.penNames {
      itemData[key]? += penNames
    }

    return itemData
  }

  func loadOnBoardingCellNodeData(indexPath: IndexPath, completionBlock: @escaping (_ indexPath: IndexPath, _ success: Bool, _ dictionary: [String : [CellNodeDataItemModel]]?) -> ()) {
    let index = indexPath.row
    loadCuratedCollectionItems(index: index) { (success, dictionary) in
      completionBlock(indexPath, success, dictionary)
    }
  }
}

// MARK: - APIS
extension OnBoardingViewModel {
  func loadCuratedCollectionItems(index: Int, completionBlock: @escaping (_ success: Bool, _ dictionary: [String : [CellNodeDataItemModel]]?) -> ()) {
    guard let items: [String : [CuratedCollectionItem]] = topicsToFollowSection(for: index) else {
      completionBlock(false, nil)
      return
    }
    let values: [CuratedCollectionItem] = items.flatMap { (item: (key: String, value: [CuratedCollectionItem])) -> [CuratedCollectionItem] in
      return item.value
    }
    let itemIds: [String] = values.flatMap { (item) -> String? in
      return item.wittyId
    }

    _ = UserAPI.batch(identifiers: itemIds) { (success, resources, error) in
      var dictionary: [String : [CellNodeDataItemModel]] = [:]
      defer {
        completionBlock(success, dictionary)
      }
      guard let resources = resources else {
        return
      }
      //create dictionary
      dictionary = self.createDataModelDictionary(with: resources, from: self.convertToIdsDic(items: items))
    }
  }

  func loadCuratedCollectionPenNames(index: Int, completionBlock: @escaping (_ success: Bool, _ dictionary: [String : [CellNodeDataItemModel]]?) -> ()) {
    guard let items: [String : [String]]  = penNamesOnBoardingData(index: index) else {
      completionBlock(false, nil)
      return
    }
    let values: [String] = items.flatMap { (item: (key: String, value: [String])) -> [String] in
      return item.value
    }

    _ = GeneralAPI.batchPenNames(identifiers: values, completion: { (success, resources, error) in
      var dictionary: [String : [CellNodeDataItemModel]] = [:]
      defer {
        completionBlock(success, dictionary)
      }
      guard let resources = resources else {
        return
      }
      //create dictionary
      dictionary = self.createDataModelDictionary(with: resources, from: items)
    })
  }
}

// MARK: - Utility Helpers
extension OnBoardingViewModel {
  func isModelSupport(resource: Resource) -> Bool {
    return (resource.registeredResourceType == PenName.resourceType || resource.registeredResourceType == Topic.resourceType)
  }

  func createDataModelDictionary(with resources: [Resource], from items: [String : [String]]) -> [String : [CellNodeDataItemModel]] {
    var dictionary: [String : [CellNodeDataItemModel]] = [:]
    for resource in resources {
      if isModelSupport(resource: resource),
        let commonResource = resource as? ModelCommonProperties {
        let model: CellNodeDataItemModel = (commonResource.id, commonResource.title, commonResource.shortDescription, commonResource.thumbnailImageUrl, commonResource.following, commonResource.registeredResourceType)
        if let id = commonResource.id,
          let key = getRelatedKey(for: id, from: items) {
          if dictionary[key] == nil {
            dictionary[key] = []
          }
          dictionary[key]? += [model]
        }
      }
    }
    return dictionary
  }

  func getRelatedKey(for id: String, from items: [String : [String]]) -> String? {
    let filteredDictionary = items.filter({ (dictionaryItem: (key: String, value: [String])) -> Bool in
      return dictionaryItem.value.filter({ (curatedPenNameId) -> Bool in
        return curatedPenNameId == id
      }).count >= 1
    })
    guard filteredDictionary.count > 0 else {
      return nil
    }
    return filteredDictionary[0].key
  }

  func convertToIdsDic(items: [String : [CuratedCollectionItem]]) -> [String : [String]] {
    var dictionary: [String: [String]] = [:]
    items.forEach { (item: (key: String, value: [CuratedCollectionItem])) in
      dictionary[item.key] = item.value.flatMap({ $0.wittyId })
    }
    return dictionary
  }
}

// MARK: - follow / unfollow
extension OnBoardingViewModel {
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

