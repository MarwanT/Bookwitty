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
  fileprivate var excludedDraftIdentifier: String?
  fileprivate var nextPage: URL?
  
  func exclude(_ identifier: String?) {
    self.excludedDraftIdentifier = identifier
  }

  func loadDrafts(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let id = UserManager.shared.defaultPenName?.id else {
      completion(false, nil)
      return
    }

    _ = PenNameAPI.penNameContent(identifier: id, status: .draft) {
      (success, resources, nextUrl, error) in
      self.drafts = resources?.filter({ $0.id != self.excludedDraftIdentifier }) ?? []
      self.nextPage = nextUrl
      completion(success, error)
    }
  }

  func deleteDraft(at row: Int, closure: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let draft = resource(at: row),
    let identifier = draft.id else {
      closure(false, nil)
      return
    }

    _ = PublishAPI.removeContent(contentIdentifier: identifier) { (success, error) in

      defer {
        closure(success, error)
      }

      guard success else {
        return
      }

      self.drafts.remove(at: row)
    }
  }

  func loadLatestVersionOfPost(with identifier: String, closure: @escaping (_ success: Bool, _ resource: ModelResource?, _ error: BookwittyAPIError?) -> Void) {
    _ = GeneralAPI.content(of: identifier, include: nil) {
      (success: Bool, post: Text?, error: BookwittyAPIError?) in
      closure(success, post as? ModelResource, error)
    }
  }

  func resource(at index: Int) -> ModelResource? {
    guard index >= 0, index < drafts.count else {
      return nil
    }

    return drafts[index]
  }
}

//MARK: - Collection Helpers
extension DraftsViewModel {
  func numberOfRows() -> Int {
    return drafts.count
  }

  func values(for item: Int) -> (title: String?, lastUpdated: NSDate?, editable: Bool) {
    guard let draft = resource(at: item) as? ModelCommonProperties else {
      return (nil, nil, false)
    }

    return (draft.title, draft.updatedAt, draft is CandidatePost)
  }
}

//MARK: - Next Page
extension DraftsViewModel {
  func hasNextPage() -> Bool {
    return nextPage != nil
  }

  func loadNext(closure: ((_ success: Bool)->())?) {
    guard let next = nextPage else {
      closure?(false)
      return
    }

    _ = GeneralAPI.nextPage(nextPage: next) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in

      self.nextPage = next
      self.drafts += resources?.filter({ $0.id != self.excludedDraftIdentifier }) ?? []
      closure?(success)
    }
  }
}
