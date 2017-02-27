//
//  CategoryViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class CategoryViewModel {
  fileprivate var curatedCollection: CuratedCollection? = nil
  fileprivate var featuredContents: [ModelCommonProperties]? = nil
  fileprivate var categoryBooks: [Book]? = nil
  fileprivate var readingLists: [ReadingList]? = nil
  fileprivate var banner: Banner? = nil
  
  
  // MARK: API Calls

  private func loadCuratedContent(categoryIdentifier: String, completion: @escaping (_ success: Bool, _ identifiers: [String]? , _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return CategoryAPI.categoryCuratedContent(categoryIdentifier: categoryIdentifier, completion: {
      (success, collection, error) in
      var identifiers = [String]()
      
      guard success, let collection = collection else {
        completion(false, nil, BookwittyAPIError.undefined)
        return
      }
      
      self.curatedCollection = collection
      self.featuredContents = nil
      self.categoryBooks = nil
      self.readingLists = nil
      self.banner = nil
      
      guard let sections = collection.sections  else {
        completion(true, nil, nil)
        return
      }
      
      if let featuredContent = sections.featuredContent {
        let featuredContentIdentifiers = featuredContent.flatMap({ $0.wittyId })
        identifiers += featuredContentIdentifiers
      }
      if let readingListIdentifiers = sections.readingListIdentifiers {
        identifiers += readingListIdentifiers
      }
      
      completion(success, identifiers, error)
    })
  }
}
