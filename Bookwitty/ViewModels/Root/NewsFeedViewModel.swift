//
//  NewsFeedViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

final class NewsFeedViewModel {
  let viewController = localizedString(key: "news", defaultValue: "News")
  var data: [Resource] = []

  func numberOfSections() -> Int {
    return data.count > 0 ? 1 : 0
  }

  func numberOfItemsInSection() -> Int {
    return data.count
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard data.count > index else { return nil }
    let resource = data[index]
    return BaseCardPostNode() //TODO: Replace with CardRegistry.getCard(resource: resource)
  }
}
