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

  func sharingContent() -> String? {
    guard let commonProperties = resource as? ModelCommonProperties else {
      return nil
    }

    let content = resource
    //TODO: Make sure that we are sharing the right information
    let shortDesciption = commonProperties.shortDescription ?? commonProperties.title ?? ""
    if let sharingUrl = content?.url {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return sharingString
    }

    //TODO: Remove dummy data and return nil instead since we do not have a url to share.
    var sharingString = "https://bookwitty-api-qa.herokuapp.com/reading_list/ios-mobile-applications-development/58a6f9b56b2c581af13637f6"
    sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
    return sharingString
  }
  
}
