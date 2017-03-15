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
  var conculsion: String? {
    return conclusionFromResource(resource: resource)
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
  var canonicalURL: URL? {
    return resource.canonicalURL
  }
  var isWitted: Bool {
    return  (resource as? ModelCommonProperties)?.isWitted ?? false
  }
  var identifier: String? {
    return resource.id
  }
  var contentPostsResources: [Resource]?

  //Resource Related Books
  var relatedBooks: [Book] = []
  //Resource Related Posts
  var relatedPosts: [Resource] = []

  init(resource: Resource) {
    self.resource = resource
  }

  private func conclusionFromResource(resource: Resource) -> String? {
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      return (resource as? ReadingList)?.conclusion
    case Text.resourceType:
      return nil
    default: return nil
    }
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
      return (resource as? ReadingList)?.postsRelations
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

  func shouldLoadContentPosts() -> Bool {
    guard let content = contentPostsIdentifiers,
      content.count > 0 else {
        return false
    }
    return true
  }

  func contentPostsItem(at index: Int) -> Resource? {
    guard let contentPostsResources = contentPostsResources,
      contentPostsResources.count > index else {
        return nil
    }
    return contentPostsResources[index]
  }

  func contentPostsItemCount() -> Int {
    return contentPostsResources?.count ?? 0
  }

  func loadContentPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let listOfIdentifiers = contentPostsIdentifiers?.prefix(20).flatMap({ $0.id }) else {
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

  func witPost(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = identifier else {
      return completionBlock(false)
    }
    witContent(contentId: contentId, completionBlock: completionBlock)
  }

  func unwitPost(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = identifier else {
      return completionBlock(false)
    }
    unwitContent(contentId: contentId, completionBlock: completionBlock)
  }

  func sharingPost() -> [String]? {
    return sharingContent(resource: resource)
  }
}

// MARK: - Related Books Section
extension PostDetailsViewModel {
  func numberOfRelatedBooks() -> Int {
    return relatedBooks.count
  }

  func relatedBook(at item: Int) -> Book? {
    guard item >= 0 && item < relatedBooks.count else {
      return nil
    }

    return relatedBooks[item]
  }

  func getRelatedBooks(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.posts(contentIdentifier: identifier, type: [Book.resourceType]) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if success {
        self.relatedBooks.removeAll()
        let books = resources?.filter({ $0.registeredResourceType == Book.resourceType })
        self.relatedBooks += (books as? [Book]) ?? []
      }
    }
  }
}


// MARK: - Related Books Section
extension PostDetailsViewModel {
  func numberOfRelatedPosts() -> Int {
    return relatedPosts.count
  }

  func relatedPost(at item: Int) -> Resource? {
    guard item >= 0 && item < relatedPosts.count else {
      return nil
    }

    return relatedPosts[item]
  }

  func getRelatedPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.posts(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if success {
        self.relatedPosts.removeAll()
        self.relatedPosts += resources ?? []
      }
    }
  }

  func witRelatedPost(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = relatedPost(at: index)?.id else {
      return completionBlock(false)
    }
    witContent(contentId: contentId, completionBlock: completionBlock)
  }

  func unwitRelatedPost(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = relatedPost(at: index)?.id else {
      return completionBlock(false)
    }
    unwitContent(contentId: contentId, completionBlock: completionBlock)
  }

  func sharingRelatedPost(index: Int) -> [String]? {
    guard let resource = relatedPost(at: index) else {
      return nil
    }

    return sharingContent(resource: resource)
  }
}

// MARK: - Related Books Section
extension PostDetailsViewModel {
  func witContent(contentId: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(contentId: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func sharingContent(resource: Resource) -> [String]? {
    guard let commonProperties = resource as? ModelCommonProperties else {
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
}
