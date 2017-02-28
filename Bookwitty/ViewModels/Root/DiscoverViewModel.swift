//
//  DiscoverViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class DiscoverViewModel {
  var cancellableRequest:  Cancellable?
  var dataIdentifiers: [String] = []

  func loadDiscoverData(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = DiscoverAPI.discover { (success, curatedCollection, error) in
      defer {
        completionBlock(success)
      }

      guard let sections = curatedCollection?.sections else {
        return
      }

      if let booksIdentifiers = sections.booksIdentifiers {
        self.dataIdentifiers += booksIdentifiers
      }
      if let readingListIdentifiers = sections.readingListIdentifiers {
        self.dataIdentifiers += readingListIdentifiers
      }
      if let featuredContent = sections.featuredContent {
        self.dataIdentifiers += featuredContent
      }
    }
  }

}
