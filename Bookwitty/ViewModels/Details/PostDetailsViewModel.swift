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
  var resource: Resource

  var cancellableRequest: Cancellable?

  var bookRegistry: BookTypeRegistry = BookTypeRegistry()

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
  var resourcePenNameId: String? {
    return penNameFromResource(resource: resource)?.id
  }
  var penName: PenName? {
    get {
      guard let resourcePenNameId = resourcePenNameId else {
        return penNameFromResource(resource: resource)
      }
      return (DataManager.shared.fetchResource(with: resourcePenNameId) as? PenName) ?? penNameFromResource(resource: resource)
    }
    set {
      setPenNameFromResource(resource: resource, penName: newValue)
    }
  }
  var tags: [String]? {
    return (resource as? ModelCommonProperties)?.tags?.flatMap({ $0.title })
  }
  fileprivate var tagsRelations: [String]? {
    return (resource as? ModelCommonProperties)?.tagsRelations?.flatMap({ $0.id })
  }
  var actionInfoValue: String? {
    return (resource as? ModelCommonProperties)?.witters
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

  var wits: Int? {
    return  (resource as? ModelCommonProperties)?.counts?.wits
  }

  var comments: Int? {
    return  (resource as? ModelCommonProperties)?.counts?.comments
  }

  var identifier: String? {
    return resource.id
  }
  var contentPostsResources: [Resource]?
  var contentPostsNextPage: URL?

  //Resource Related Books
  var relatedBooks: [Book] = []
  var relatedBooksNextPage: URL?
  //Resource Related Posts
  var relatedPosts: [String] = []
  var relatedPostsNextPage: URL?

  init(resource: Resource) {
    self.resource = resource
  }

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
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

  private func setPenNameFromResource(resource: Resource, penName: PenName?) {
    guard let penName = penName else {
      return
    }
    switch(resource.registeredResourceType) {
    case ReadingList.resourceType:
      (resource as? ReadingList)?.penName = penName
    case Text.resourceType:
      (resource as? Text)?.penName = penName
    default: return
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

  func loadPenName(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penNameId = penName?.id else {
      completionBlock(false)
      return
    }
    _ = PenNameAPI.penNameDetails(identifier: penNameId, completionBlock: { (success, penName, error) in
      defer {
        completionBlock(success)
      }
      if let penName = penName, success {
         DataManager.shared.update(resource: penName)
        self.penName = penName
      }
    })
  }

  func loadContentPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }
    let pageSize: String = String(20)
    let page: (number: String?, size: String?) = (nil, pageSize)
    _ = GeneralAPI.postsContent(contentIdentifier: identifier, page: page) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.contentPostsResources = resources
        self.contentPostsNextPage = next
      }
    }
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
      DataManager.shared.update(resources: result)
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

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: [Book.resourceType]) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.relatedBooks.removeAll()
        let books = resources.filter({ $0.registeredResourceType == Book.resourceType })
        self.relatedBooks += (books as? [Book]) ?? []
        self.relatedBooksNextPage = next
      }
    }
  }
}


// MARK: - Related Books Section
extension PostDetailsViewModel {

  func deleteResource(with identifier: String) {
    if let index = relatedPosts.index(where: { $0 == identifier }) {
      relatedPosts.remove(at: index)
    }
  }

  func updateAffectedPostDetails(resourcesIdentifiers: [String]) -> Bool {
    guard resourcesIdentifiers.count > 0 else {
      return false
    }

    if let resourceId = resource.id {
      return resourcesIdentifiers.contains( where: { $0 == resourceId } )
    }
    return false
  }
  
  func relatedPostsResourceValues(for index: Int) -> (followingMode: Bool, following: Bool, isWitted: Bool,wits: Int)? {
    guard let modelResource = relatedPostsResourceForIndex(index: index), let resource = modelResource as? ModelCommonProperties else {
      return nil
    }

    func canFollowedResource(resource: ModelResource) -> Bool { return (resource.registeredResourceType == Topic.resourceType) || (resource.registeredResourceType == Author.resourceType) || (resource.registeredResourceType == Book.resourceType) || (resource.registeredResourceType == PenName.resourceType) }

    func isFollowingResource(resource: ModelResource) -> Bool {
      switch (resource.registeredResourceType) {
      case Topic.resourceType:
        return (resource as? Topic)?.following ?? false
      case PenName.resourceType:
        return (resource as? PenName)?.following ?? false
      case Book.resourceType:
        return (resource as? Book)?.following ?? false
      case Author.resourceType:
        return (resource as? Author)?.following ?? false
      default: return false
      }
    }

    //TODO: Replace with resource.canBeFollowed when implemented
    let canBeFollowed = canFollowedResource(resource: modelResource)
    //TODO: Replace with resource.following when implemented
    let following = isFollowingResource(resource: modelResource)

    let wits = resource.counts?.wits ?? 0
    return (followingMode: canBeFollowed, following: following, isWitted: resource.isWitted, wits: wits)
  }

  func relatedPostsAffectedItems(identifiers: [String], visibleItemsIndices: [Int]) -> [Int] {
    //let affectedCardItems = relatedPosts.filter({ identifiers.contains($0) }).flatMap({ relatedPosts.index(of: $0) })
    return visibleItemsIndices.filter({
      index in
      guard let resource = relatedPostsResourceForIndex(index: index) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return identifiers.contains(identifier)
    })
  }

  func relatedPostsResources() -> [ModelResource] {
    return DataManager.shared.fetchResources(with: relatedPosts)
  }

  func relatedPostsResourceForIndex(index: Int) -> ModelResource? {
    guard relatedPosts.count > index else { return nil }
    let resource = resourceFor(id: relatedPosts[index])
    return resource
  }

  func numberOfRelatedPosts() -> Int {
    return relatedPosts.count
  }

  func relatedPost(at item: Int) -> Resource? {
    guard item >= 0 && item < relatedPosts.count else {
      return nil
    }

    return relatedPostsResourceForIndex(index: item)
  }

  func getRelatedPosts(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let identifier = identifier else {
      return
    }

    _ = GeneralAPI.postsLinkedContent(contentIdentifier: identifier, type: nil) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      defer {
        completionBlock(success)
      }
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.postDetails)

        self.relatedPosts.removeAll()
        self.relatedPosts += resources.flatMap( { $0.id })
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
    guard let readingList = relatedPost(at: index) as? ReadingList,
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

// MARK: - Related Books Section
extension PostDetailsViewModel {
  func witContent(contentId: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(contentId: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: .unwit)
      }
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
      return [shortDesciption, sharingUrl.absoluteString]
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
      if success {
        DataManager.shared.updateResource(with: identifier, after: .follow)
      }
      completionBlock(success)
    }
  }

  func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let penName = penName, let identifier = penName.id else {
      completionBlock(false)
      return
    }

    _ = GeneralAPI.unfollowPenName(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: .unfollow)
      }
      completionBlock(success)
    }
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: .follow)
      }
      completionBlock(success)
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: .unfollow)
      }
      completionBlock(success)
    }
  }
}
