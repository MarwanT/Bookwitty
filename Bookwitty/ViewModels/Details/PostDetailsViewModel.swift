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
  var isDimmed: Bool {
    return  (resource as? ModelCommonProperties)?.isDimmed ?? false
  }
  var wits: Int? {
    return  (resource as? ModelCommonProperties)?.counts?.wits
  }
  var dims: Int? {
    return  (resource as? ModelCommonProperties)?.counts?.dims
  }
  var identifier: String? {
    return resource.id
  }
  var contentPostsResources: [Resource]?

  //Resource Related Books
  var relatedBooks: [Book] = []
  var relatedBooksNextPage: URL?
  //Resource Related Posts
  var relatedPosts: [Resource] = []
  var relatedPostsNextPage: URL?

  init(resource: Resource) {
    self.resource = resource
  }

  func isMyPenName() -> Bool {
    guard let penName = penName else {
      return false
    }
    return UserManager.shared.isMy(penName: penName)
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

  func dimContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = identifier else {
      return completionBlock(false)
    }

    cancellableRequest = NewsfeedAPI.dim(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func undimContent(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let contentId = identifier else {
      return completionBlock(false)
    }

    cancellableRequest = NewsfeedAPI.undim(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
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
        self.relatedBooksNextPage = next
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
        self.relatedPostsNextPage = next
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

// MARK: - Related Posts
extension PostDetailsViewModel {
  func loadReadingListImages(atIndex index: Int, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let readingList = relatedPost(at: index) as? ReadingList else {
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


// MARK: - PenName Follow/Unfollow
extension PostDetailsViewModel {
  func followRelatedPost(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = relatedPost(at: index) else {
      completionBlock(false)
      return
    }
    follow(resource: resource, completionBlock: completionBlock)
  }

  func unfollowRelatedPost(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = relatedPost(at: index) else {
      completionBlock(false)
      return
    }
    unfollow(resource: resource, completionBlock: completionBlock)
  }

  func follow(resource: Resource, completionBlock: @escaping (_ success: Bool) -> ()) {
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

  func unfollow(resource: Resource, completionBlock: @escaping (_ success: Bool) -> ()) {
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

  func followPostPenName(completionBlock: @escaping (_ success: Bool) -> ()) {
    followPenName(penName: self.penName, completionBlock: completionBlock)
  }

  func unfollowPostPenName(completionBlock: @escaping (_ success: Bool) -> ()) {
    unfollowPenName(penName: self.penName, completionBlock: completionBlock)
  }

  func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
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

  func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
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
