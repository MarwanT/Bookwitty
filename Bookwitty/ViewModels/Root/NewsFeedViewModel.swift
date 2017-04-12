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
  var data: [ModelResource] = [] {
    didSet {
      if data.count == 0 {
        nextPage = nil
      }
    }
  }
  var penNames: [PenName] {
    return UserManager.shared.penNames ?? []
  }
  var defaultPenName: PenName? {
    return UserManager.shared.defaultPenName
  }
  var misfortuneNodeMode: MisfortuneNode.Mode? = MisfortuneNode.Mode.empty

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
    guard data.count > index,
      let contentId = data[index].id else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard data.count > index,
      let contentId = data[index].id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func cancellableOnGoingRequest() {
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }
  }

  func penNameRequest(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableOnGoingRequest()
    _ = PenNameAPI.getPenNames { (success, penNames, error) in
      completionBlock(success)
    }
  }

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }
    cancellableRequest = NewsfeedAPI.feed() { (success, resources, nextPage, error) in
      if success {
        self.data.removeAll(keepingCapacity: false)
        self.data = resources ?? []
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
      
      // Set misfortune node mode
      if self.data.count > 0 {
        self.misfortuneNodeMode = nil
      } else {
        if let isReachable = AppManager.shared.reachability?.isReachable, !isReachable {
          self.misfortuneNodeMode = MisfortuneNode.Mode.noInternet
        } else {
          self.misfortuneNodeMode = MisfortuneNode.Mode.empty
        }
      }
      
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
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }

    cancellableRequest = NewsfeedAPI.nextFeedPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        self.data += resources
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
      completionBlock(success)
    }
  }

  func sharingContent(index: Int) -> [String]? {
    guard data.count > index,
    let commonProperties = data[index] as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return [sharingUrl.absoluteString, shortDesciption]
    }
    return [shortDesciption]
  }

  func numberOfSections() -> Int {
    return NewsFeedViewController.Section.numberOfSections
  }

  func numberOfItemsInSection(section: Int) -> Int {
    return data.count
  }

  func resourceForIndex(index: Int) -> ModelResource? {
    guard data.count > index else { return nil }
    let resource = data[index]
    return resource
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = resourceForIndex(index: index) else {
      return nil
    }

    return CardFactory.shared.createCardFor(resource: resource)
  }

  func loadReadingListImages(atIndex index: Int, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = resourceForIndex(index: index) as? ReadingList else {
      completionBlock(nil)
        return
    }
    var ids: [String] = []
    if let list = readingList.postsRelations {
      for item in list {
        ids.append(item.id)
      }
    }
    if ids.count > 0 {
      let limitToMaximumIds = Array(ids.prefix(maxNumberOfImages))
      loadReadingListItems(readingListIds: limitToMaximumIds, completionBlock: completionBlock)
    } else {
      completionBlock(nil)
    }
  }

  private func loadReadingListItems(readingListIds: [String], completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    _ = UserAPI.batch(identifiers: readingListIds) { (success, resources, error) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if success {
        var images: [String] = []
        resources?.forEach({ (resource) in
          if let res = resource as? ModelCommonProperties {
            if let imageUrl = res.thumbnailImageUrl {
              images.append(imageUrl)
            }
          }
        })
        imageCollection = images
      }
    }
  }
}

// MARK: - PenName Follow/Unfollow
extension NewsFeedViewModel {
  func follow(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
          let resourceId = resource.id else {
      completionBlock(false)
      return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      followPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      followRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  func unfollow(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic - Author - Book - PenName
    if resource.registeredResourceType == PenName.resourceType {
      //Only If Resource is a pen-name
      unfollowPenName(penName: resource as? PenName, completionBlock: completionBlock)
    } else {
      //Types: Topic - Author - Book
      unfollowRequest(identifier: resourceId, completionBlock: completionBlock)
    }
  }

  fileprivate func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.followPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      penName.following = true
    }
  }

   fileprivate func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      penName.following = false
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
    }
  }
}
