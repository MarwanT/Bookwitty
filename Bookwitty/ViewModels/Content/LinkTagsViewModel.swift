//
//  LinkTagsViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 10/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class LinkTagsViewModel {
  var canLink: Bool = true
  var tags: [Tag] = []
  let filter: Filter = Filter()
  
  init() {
    self.filter.types = [Tag.resourceType]
  }
}
