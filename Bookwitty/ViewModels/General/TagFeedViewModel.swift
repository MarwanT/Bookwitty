//
//  TagFeedViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class TagFeedViewModel {

  var tag: Tag? = nil
  var nextPage: URL?

  var data: [String] = [] {
    didSet {
      if data.count == 0 {
        nextPage = nil
      }
    }
  }

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func resourceForIndex(index: Int) -> ModelResource? {
    guard index >= 0, data.count > index else { return nil }
    let resource = resourceFor(id: data[index])
    return resource
  }

  func loadTagDetails(completion: @escaping (_ success: Bool)->()) {
    guard let identifier = tag?.id else {
      completion(false)
      return
    }

    _ = GeneralAPI.content(of: identifier, include: nil, completion: { (success: Bool, tag: Tag?, error: BookwittyAPIError?) in
      defer {
        completion(success)
      }

      guard success, let tag = tag else {
        return
      }

      self.tag = tag
      DataManager.shared.update(resource: tag)
    })
  }

  func loadFeeds(completion: @escaping (_ success: Bool)->()) {
    guard let identifier = tag?.id else {
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success)
      }

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.data.removeAll()
        self.data += resources.flatMap( { $0.id })
        self.nextPage = next
      }
    }
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }

  func loadNext(completion: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completion(false)
      return
    }

    _ = GeneralAPI.nextPage(nextPage: nextPage) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completion(success)
      }

      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.data += resources.flatMap( { $0.id })
        self.nextPage = next
      }
    }
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

}

//MARK: - Wit / Unwit
extension TagFeedViewModel {
  func witContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }

    _ = NewsfeedAPI.wit(contentId: resourceId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: resourceId, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(index: index),
      let resourceId = resource.id else {
        completionBlock(false)
        return
    }

    _ = NewsfeedAPI.unwit(contentId: resourceId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: resourceId, after: DataManager.Action.unwit)
      }
      completionBlock(success)
    })
  }
}

// MARK: - Share
extension TagFeedViewModel {
  func sharingContent(index: Int) -> [String]? {
    guard let commonProperties = resourceForIndex(index: index) as? ModelCommonProperties else {
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
}

// MARK: - PenName Follow/Unfollow
extension TagFeedViewModel {
  func followTag(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = self.tag?.id else {
      completionBlock(false)
      return
    }

    followRequest(identifier: identifier, completionBlock: completionBlock)
  }

  func unfollowTag(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = self.tag?.id else {
      completionBlock(false)
      return
    }

    unfollowRequest(identifier: identifier, completionBlock: completionBlock)
  }

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
