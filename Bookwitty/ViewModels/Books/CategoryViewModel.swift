//
//  CategoryViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

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
  
  private func loadContentDetails(identifiers: [String], completion: @escaping (_ success: Bool, _ readingList: ReadingList?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: identifiers, completion: {
      (success, resources, error) in
      var readingList: ReadingList? = nil
      defer {
        completion(success, readingList, error)
      }
      
      guard success, let resources = resources else {
        return
      }
      
      if let featuredContents = self.curatedCollection?.sections?.featuredContent {
        self.featuredContents = self.filterFeaturedContents(featuredContents: featuredContents, resources: resources)
      }
      
      if let readingListsIdentifiers = self.curatedCollection?.sections?.readingListIdentifiers {
        self.readingLists = self.filterReadingLists(readingListsIdentifiers: readingListsIdentifiers, resources: resources)
      }
    })
  }
  
  
  // MARK: Filters
  
  private func filterFeaturedContents(featuredContents: [FeaturedContent], resources: [Resource]) -> [ModelCommonProperties] {
    var filteredContent = [ModelCommonProperties]()
    
    let postIds = featuredContents.flatMap({ $0.wittyId })
    for postId in postIds {
      guard let resource = resources.filter({ $0.id == postId }).first as? ModelCommonProperties else {
        continue
      }
      filteredContent.append(resource)
    }
    
    return filteredContent
  }
  
  private func filterReadingLists(readingListsIdentifiers: [String], resources: [Resource]) -> [ReadingList] {
    var readingLists = [ReadingList]()
    for readingListIdentifier in readingListsIdentifiers {
      guard let resource = resources.filter({ $0.id == readingListIdentifier }).first as? ReadingList else {
        continue
      }
      readingLists.append(resource)
    }
    return readingLists
  }
}
