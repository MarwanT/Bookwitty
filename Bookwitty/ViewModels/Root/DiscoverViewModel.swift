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

  func loadDiscoverData(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = DiscoverAPI.discover { (success, curatedCollection, error) in
      //TODO: handle result
      completionBlock(success)
    }
  }

}
