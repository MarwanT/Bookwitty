//
//  NewsFeedViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

final class NewsFeedViewModel {
  var cancellableRequest:  Cancellable?
  var nextPage: URL?
  var data: [ModelResource] = []
  var penNames: [PenName] {
    return UserManager.shared.penNames ?? []
  }
  var defaultPenName: PenName? {
    return UserManager.shared.defaultPenName
  }

  func didUpdateDefaultPenName(penName: PenName, completionBlock: (_ didSaveDefault: Bool) -> ()) {
    var didSaveDefault: Bool = false
    defer {
      completionBlock(didSaveDefault)
    }

    if let oldPenNameId = defaultPenName?.id {
      //Cached Pen-Name Id
      if let newPenNameId = penName.id, newPenNameId != oldPenNameId {
        UserManager.shared.saveDefaultPenName(penName: penName)
        didSaveDefault = true
      }
      //Else do nothing: Since the default PenName did not change.
    } else {
      //Save Default Pen-Name
      UserManager.shared.saveDefaultPenName(penName: penName)
      didSaveDefault = true
    }
  }

  func witContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
      let contentId = data[dataIndex].id else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
      let contentId = data[dataIndex].id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.feed() { (success, resources, nextPage, error) in
      self.data = resources ?? []
      self.nextPage = nextPage
      completionBlock(success)
    }
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }

  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.nextFeedPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        self.data += resources
        self.nextPage = nextPage
      }
      completionBlock(success)
    }
  }

  func sharingContent(index: Int) -> String? {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
    let commonProperties = data[dataIndex] as? ModelCommonProperties else {
        return nil
    }

    let content = data[dataIndex]
    //TODO: Make sure that we are sharing the right information
    let shortDesciption = commonProperties.shortDescription ?? commonProperties.title ?? ""
    if let sharingUrl = content.url {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return sharingString
    }

    //TODO: Remove dummy data and return nil instead since we do not have a url to share.
    var sharingString = "https://bookwitty-api-qa.herokuapp.com/reading_list/ios-mobile-applications-development/58a6f9b56b2c581af13637f6"
    sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
    return sharingString
  }

  func hasPenNames() -> Bool {
    return penNames.count > 0
  }

  func numberOfSections() -> Int {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    return data.count > 0 ? 1 : showsPenNameSelectionHeader
  }

  func numberOfItemsInSection() -> Int {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    return data.count + showsPenNameSelectionHeader
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex else { return nil }
    let resource = data[dataIndex]
    return CardFactory.shared.createCardFor(resource: resource)
  }
}
