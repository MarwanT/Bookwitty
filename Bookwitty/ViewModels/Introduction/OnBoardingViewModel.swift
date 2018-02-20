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
    let queue = DispatchGroup()
    var topicsDictionary: [String : [CellNodeDataItemModel]] = [:]
    var pennamesDictionary: [String : [CellNodeDataItemModel]] = [:]
    var mergedSuccess: Bool = false

    queue.enter()
    loadCuratedCollectionItems(index: index) { (success: Bool, result: [String : [CellNodeDataItemModel]]?) in
      mergedSuccess = success || mergedSuccess
      if let result = result {
        topicsDictionary = result
      }
      queue.leave()
    }

    queue.enter()
    loadCuratedCollectionPenNames(index: index) { (success: Bool, result: [String : [CellNodeDataItemModel]]?) in
      mergedSuccess = success || mergedSuccess
      if let result = result {
        pennamesDictionary = result
      }
      queue.leave()
    }

    queue.notify(queue: DispatchQueue.main) {
      //Sorting / Ordering dictionary values depends on who is left and who is right of the mergery
      let dictionary: [String : [CellNodeDataItemModel]] = mergeDictionaries(left: topicsDictionary, right: pennamesDictionary)
      completionBlock(indexPath, mergedSuccess, dictionary)
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

  func completeOnBoarding() {
    guard let identifier = UserManager.shared.signedInUser.id else {
      return
    }
    
    UserManager.shared.didOpenOnboarding = true

    _ = UserAPI.updateUser(identifier: identifier, completeOnboarding: true) { (_, _, _) in
    }
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
      if isModelSupport(resource: resource), let commonResource = resource as? ModelCommonProperties,
        let id = commonResource.id, let key = getRelatedKey(for: id, from: items) {
        let model: CellNodeDataItemModel = (commonResource.id, commonResource.title, commonResource.shortDescription, commonResource.thumbnailImageUrl, commonResource.following, commonResource.registeredResourceType)
        dictionary[key] = (dictionary[key] ?? []) + [model]
      }
    }
    return dictionary
  }

  func getRelatedKey(for id: String, from items: [String : [String]]) -> String? {
    var candidateKey: String?
    for dictionaryItem in items {
      if dictionaryItem.value.contains(id) {
        candidateKey = dictionaryItem.key
        break
      }
    }
    return candidateKey
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
  func follow(identifier: String, resourceType: ResourceType, completionBlock: @escaping (_ success: Bool) -> ()) {
    switch resourceType {
    case PenName.resourceType:
      followPenName(identifier: identifier, completionBlock: completionBlock)
    default:
      followRequest(identifier: identifier, completionBlock: completionBlock)
    }
  }

  func unfollow(identifier: String, resourceType: ResourceType, completionBlock: @escaping (_ success: Bool) -> ()) {
    switch resourceType {
    case PenName.resourceType:
      unfollowPenName(identifier: identifier, completionBlock: completionBlock)
    default:
      unfollowRequest(identifier: identifier, completionBlock: completionBlock)
    }
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

  fileprivate func followPenName(identifier: String?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }

  fileprivate func unfollowPenName(identifier: String?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }
}

