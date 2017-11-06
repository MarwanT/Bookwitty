//
//  SearchViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

class SearchViewModel {
  var data: [String] = []
  var cancellableRequest: Cancellable?
  var nextPage: URL?

  var facet: Facet?
  var filter: Filter = Filter()
  
  var misfortuneNodeMode: MisfortuneNode.Mode? = nil
  var bookRegistry: BookTypeRegistry = BookTypeRegistry()

  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func cancelActiveRequest() {
    guard let cancellableRequest = cancellableRequest else {
      return
    }
    if !cancellableRequest.isCancelled {
      cancellableRequest.cancel()
    }
  }

  func clearSearchData() {
    //Cancel any on-goin request
    cancelActiveRequest()
    self.data.removeAll(keepingCapacity: false)
  }

  func search(query: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    //Cancel any on-goin request
    cancelActiveRequest()

    self.data.removeAll(keepingCapacity: false)
    cancellableRequest = SearchAPI.search(filter: filter, page: nil, includeFacets: true, completion: {
      (success, resources, nextPage, facet, error) in
      defer {
        // Set misfortune node mode
        if self.data.count > 0 {
          self.misfortuneNodeMode = nil
        } else {
          if let isReachable = AppManager.shared.reachability?.isReachable, !isReachable {
            self.misfortuneNodeMode = MisfortuneNode.Mode.noInternet
          } else {
            self.misfortuneNodeMode = MisfortuneNode.Mode.noResultsFound
          }
        }
        completion(success, error)
      }
      
      guard success, let resources = resources else {
        return
      }

      DataManager.shared.update(resources: resources)
      self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.search)

      self.data += resources.flatMap({ $0.id })
      self.nextPage = nextPage
      self.facet = facet
    })
  }

  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completionBlock(false)
      return
    }
    //Cancel any on-goin request
    cancelActiveRequest()

    cancellableRequest = GeneralAPI.nextPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        self.bookRegistry.update(resources: resources, section: BookTypeRegistry.Section.search)

        self.data += resources.flatMap({ $0.id })
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
      completionBlock(success)
    }
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }

  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(indexPath: indexPath) as? ModelCommonProperties, let identifier = resource.id else {
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

//MARK: - Filter helper
extension SearchViewModel {
  func filterDictionary() -> [String : String] {
    var dictionary = [String : String]()

    if let category = self.filter.categories.first?.key {
      dictionary["category"] = category
    }

    if let language = self.filter.languages.first {
      dictionary["language"] = language
    }

    if let type = self.filter.types.first {
      dictionary["type"] = type
    }
    return dictionary
  }
}

// Mark: - Collection helper
extension SearchViewModel {
  func numberOfSections() -> Int {
    return SearchViewController.Section.numberOfSections
  }

  func numberOfItemsInSection(section: Int) -> Int {
    return SearchViewController.Section.activityIndicator.rawValue == section ? 1 : data.count
  }

  func resourceForIndex(indexPath: IndexPath) -> ModelResource? {
    guard data.count > indexPath.row else { return nil }
    let resourceId = data[indexPath.row]
    return resourceFor(id: resourceId)
  }

  func nodeForItem(atIndexPath indexPath: IndexPath) -> BaseCardPostNode? {
    guard let resource = resourceForIndex(indexPath: indexPath) else {
      return nil
    }

    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }
}

// Mark: - Reading List
extension SearchViewModel {
  func loadReadingListImages(atIndexPath indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {    
    guard let readingList = resourceForIndex(indexPath: indexPath) as? ReadingList,
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

// MARK: - Posts Actions
extension SearchViewModel {
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
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

  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
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

  func sharingContent(indexPath: IndexPath) -> [String]? {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let commonProperties = resource as? ModelCommonProperties else {
        return nil
    }

    let shortDesciption = commonProperties.title ?? commonProperties.shortDescription ?? ""
    if let sharingUrl = commonProperties.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}

// MARK: - PenName Follow/Unfollow
extension SearchViewModel {
  func follow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
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

  func unfollow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
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

  func followPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
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

  func unfollowPenName(penName: PenName?, completionBlock: @escaping (_ success: Bool) -> ()) {
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

