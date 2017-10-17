//
//  DraftsViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/16.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class DraftsViewModel {
  fileprivate var drafts: [ModelResource] = []
  fileprivate var nextPage: URL?

  func loadDrafts(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let id = UserManager.shared.defaultPenName?.id else {
      completion(false, nil)
      return
    }

    _ = PenNameAPI.penNameContent(identifier: id, status: .draft) {
      (success, resources, nextUrl, error) in
      self.drafts = resources ?? []
      self.nextPage = nextUrl
      completion(success, error)
    }
  }

  fileprivate func resource(at index: Int) -> ModelResource? {
    guard index >= 0, index < drafts.count else {
      return nil
    }

    return drafts[index]
  }
}
