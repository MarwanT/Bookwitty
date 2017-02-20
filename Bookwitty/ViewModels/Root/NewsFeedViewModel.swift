//
//  NewsFeedViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

final class NewsFeedViewModel {
  var cancellableRequest:  Cancellable?
  let viewController = localizedString(key: "news", defaultValue: "News")
  var data: [Resource] = []
  var selectedPenNameId: String = "6c08337a-108f-4335-b2d0-3a25b9fe6bed"

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.feed(forPenName: selectedPenNameId) { (success, resources, error) in
      self.data = resources ?? []
      completionBlock(success)
    }
  }

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

class CardRegistry {
  typealias RegEntry = () -> BaseCardPostNode

  static let sharedInstance: CardRegistry = CardRegistry()

  private var registry = [String : RegEntry]()


  func register(resource : Resource.Type, creator : @escaping () -> BaseCardPostNode) {
    registry[resource.resourceType] = creator
  }

  private init() {
    //Making Constructor Not Reachable
  }

  static func getCard(resource : Resource) -> BaseCardPostNode? {
      return nil
  }

}
