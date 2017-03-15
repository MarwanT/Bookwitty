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

  func witContent( completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      completionBlock(false)
      return
    }
    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
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

  func dimContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      return completionBlock(false)
    }

    cancellableRequest = NewsfeedAPI.dim(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func undimContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = resource.id else {
      return completionBlock(false)
    }

    cancellableRequest = NewsfeedAPI.undim(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }
}
