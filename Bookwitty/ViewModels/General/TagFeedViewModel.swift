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
}
