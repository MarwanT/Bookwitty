//
//  TagFeedViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class TagFeedViewModel {
  var data: [String] = []

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
