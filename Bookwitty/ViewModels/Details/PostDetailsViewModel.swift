//
//  PostDetailsViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine
import Moya

class PostDetailsViewModel {
  let resource: Resource

  var cancellableRequest: Cancellable?

  var vcTitle: String? {
    return vcTitleForResource(resource: resource)
  }

  var title: String? {
    return (resource as? ModelCommonProperties)?.title
  }
  var image: String? {
    return (resource as? ModelCommonProperties)?.coverImageUrl
  }
  var body: String? {
    return bodyFromResource(resource: resource)
  }
  var date: NSDate? {
    return (resource as? ModelCommonProperties)?.createdAt
  }
  var penName: PenName? {
    return penNameFromResource(resource: resource)
  }
  var contentPostsIdentifiers: [ResourceIdentifier]? {
    return contentPostsFromResource(resource: resource)
  }
  var contentPostsResources: [Resource]?

  init(resource: Resource) {
    self.resource = resource
  }

  private func bodyFromResource(resource: Resource) -> String? {
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      return (resource as? ReadingList)?.body
    case Text.resourceType:
      return (resource as? Text)?.body
    default: return nil
    }
  }

  private func penNameFromResource(resource: Resource) -> PenName? {
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      return (resource as? ReadingList)?.penName
    case Text.resourceType:
      return (resource as? Text)?.penName
    default: return nil
    }
  }

  private func contentPostsFromResource(resource: Resource) -> [ResourceIdentifier]? {
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      return (resource as? ReadingList)?.posts
    case Text.resourceType:
      return nil
    default: return nil
    }
  }

  private func vcTitleForResource(resource: Resource) -> String? {
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      return Strings.reading_list()
    case Text.resourceType:
      return Strings.article()
    default: return nil
    }
  }


  func loadContentPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let listOfIdentifiers = contentPostsIdentifiers?.prefix(10).flatMap({ $0.id }) else {
      completionBlock(false)
      return
    }

    cancellableRequest = loadBatch(listOfIdentifiers: listOfIdentifiers, completion: { (success: Bool, resources: [Resource]?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        self.contentPostsResources = resources
      }
    })
  }

  private func loadBatch(listOfIdentifiers: [String], completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: listOfIdentifiers, completion: {
      (success, resource, error) in
      var resources: [Resource]?
      defer {
        completion(success, resources, error)
      }

      guard success, let result = resource else {
        return
      }
      resources = result
    })
  }
}
