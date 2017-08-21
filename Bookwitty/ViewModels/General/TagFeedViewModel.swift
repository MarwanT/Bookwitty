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
