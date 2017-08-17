//
//  CardDetailsViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine
import Moya

class CardDetailsViewModel {
  let resource: ModelResource!

  var cancellableRequest: Cancellable?

  init(resource: ModelResource) {
    self.resource = resource
  }

  var tags: [String]? {
    return (resource as? ModelCommonProperties)?.tags?.flatMap({ $0.title })
  }

  fileprivate var tagsRelations: [String]? {
    return (resource as? ModelCommonProperties)?.tagsRelations?.flatMap({ $0.id })
  }

  func loadTags(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let tagsIdentifiers = tagsRelations, tagsIdentifiers.count > 0 else {
      completion(true, nil)
      return
    }

    _ = UserAPI.batch(identifiers: tagsIdentifiers, completion: {
      (success, resources, error) in
      guard success, let tags = resources as? [Tag] else {
        completion(success, nil)
        return
      }

      (self.resource as? ModelCommonProperties)?.tags = tags
      DataManager.shared.update(resource: self.resource)
      completion(success, nil)
    })
  }

  func witContent( completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      completionBlock(false)
      return
    }
    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.unwit)
      }
      completionBlock(success)
    })
  }

  func sharingContent() -> [String]? {
    guard let commonProperties = resource as? ModelCommonProperties else {
      return nil
    }

    let content = resource
    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = (content as? ModelCommonProperties)?.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}

// MARK: - PenName Follow/Unfollow
extension CardDetailsViewModel {
  func follow(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resourceId = resource.id else {
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

  func unfollow(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resourceId = resource.id else {
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

