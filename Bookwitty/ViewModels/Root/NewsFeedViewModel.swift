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
  var data: [String] = [] {
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
  var bookRegistry: BookTypeRegistry = BookTypeRegistry()

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
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
    guard data.count > index else {
      completionBlock(false)
      return
    }

    let id = data[index]
    cancellableRequest = NewsfeedAPI.wit(contentId: id, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: id, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard data.count > index else {
        completionBlock(false)
        return
    }
    let id = data[index]
    cancellableRequest = NewsfeedAPI.unwit(contentId: id, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: id, after: DataManager.Action.unwit)
      }
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
  
  func resetData() {
    data = []
    nextPage = nil
  }

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    if let cancellableRequest = cancellableRequest {
      cancellableRequest.cancel()
    }
    cancellableRequest = NewsfeedAPI.feed() { (success, resources, nextPage, error) in
      defer {
        completionBlock(success)
      }

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.newsFeed)

        self.data.removeAll(keepingCapacity: false)
        self.data = resources.flatMap({ $0.id })
        self.nextPage = nextPage
      } else {
        self.data = []
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
      defer {
        completionBlock(success)
      }

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.newsFeed)
        
        self.data += resources.flatMap({ $0.id })
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
    }
  }

  func sharingContent(index: Int) -> [String]? {
    guard data.count > index,
    let commonProperties = resourceForIndex(index: index) as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return [shortDesciption, sharingUrl.absoluteString]
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
    let resource = resourceFor(id: data[index])
    return resource
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = resourceForIndex(index: index) else {
      return nil
    }

    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }

  func loadReadingListImages(atIndex index: Int, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = resourceForIndex(index: index) as? ReadingList,
    let identifier = readingList.id else {
      completionBlock(nil)
        return
    }
    
    let pageSize: String = String(maxNumberOfImages)
    let page: (number: String?, size: String?) = (nil, pageSize)
    _ = GeneralAPI.postsContent(contentIdentifier: identifier, page: page) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if let resources = resources, success {
        var images: [String] = []
        resources.forEach({ (resource) in
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

  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(index: indexPath.row) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return resourcesIdentifiers.contains(identifier)
    })
  }

  func deleteResource(with identifier: String) {
    if let index = data.index(where: { $0 == identifier }) {
      data.remove(at: index)
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
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
        penName.following = true
      }
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
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
        penName.following = false
      }
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
      }
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      defer {
        completionBlock(success)
      }
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
      }
    }
  }
}

// MARK: - Introductory Banner Logic
extension NewsFeedViewModel {
  var shouldDisplayIntroductoryBanner: Bool {
    get {
      return GeneralSettings.sharedInstance.shouldDisplayNewsFeedIntroductoryBanner
    }
    set {
      GeneralSettings.sharedInstance.shouldDisplayNewsFeedIntroductoryBanner = newValue
    }
  }
}
