//
//  BookStoreViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

final class BookStoreViewModel {
  let viewAllCategoriesLabelText = localizedString(key: "view_all_categories", defaultValue: "View All Categories")
  let bookwittySuggestsTitle = localizedString(key: "bookwitty_suggests", defaultValue: "Bookwitty Suggests")
  let viewAllBooksLabelText = localizedString(key: "view_all_books", defaultValue: "View All Books")
  let viewAllSelectionsLabelText = localizedString(key: "view_all_selections", defaultValue: "View All Selections")
  let selectionHeaderTitle = localizedString(key: "our_selection_for_you", defaultValue: "Our selection for you")
  let viewControllerTitle = localizedString(key: "books", defaultValue: "Books")
  let errorLoadingDataTitle = localizedString(key: "error_loading_data_title", defaultValue: "Error Loading Data")
  let errorLoadingDataMessage = localizedString(key: "error_loading_data_message", defaultValue: "We could not load your data")
  let okText = localizedString(key: "ok", defaultValue: "Ok")
  
  private var curatedCollection: CuratedCollection? = nil
  private var featuredContents: [ModelCommonProperties]? = nil
  private var featuredReadingListContent: [Book]? = nil
  private var readingLists: [ReadingList]? = nil
  private var banner: Banner? = nil
  
  var request: Cancellable?
  
  func loadData(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    request = loadCuratedContent(completion: {
      (success, identifiers, error) in
      guard success else {
        self.request = nil
        completion(false, error)
        return
      }
      
      guard let identifiers = identifiers, identifiers.count > 0 else {
        self.request = nil
        completion(true, nil)
        return
      }

      // !!!!:
      // If data needs to be viewed partially here even before retrieving
      // content details, a block trigering a change in the vc should be called here.
      
      self.request = self.loadContentDetails(identifiers: identifiers, completion: {
        (success, readingList, error) in
        guard success, let booksIds = readingList?.posts?.flatMap({ $0.id }) else {
          self.request = nil
          completion(success, error)
          return
        }
        
        // !!!!:
        // If data needs to be viewed partially here even before retrieving
        // content details, a block trigering a change in the vc should be called here.
        
        self.request = self.loadReadingListContent(booksIds: booksIds, completion: {
          (success, error) in
          self.request = nil
          completion(success, error)
        })
      })
    })
  }
  
  private func loadCuratedContent(completion: @escaping (_ success: Bool, _ identifiers: [String]? , _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return CuratedCollectionAPI.storeFront(completion: {
      (success, collection, error) in
      var identifiers = [String]()
      
      guard success, let collection = collection else {
        completion(false, nil, BookwittyAPIError.undefined)
        return
      }
      
      self.curatedCollection = collection
      
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
        let filteredReadingLists = self.filterReadingLists(readingListsIdentifiers: readingListsIdentifiers, resources: resources)
        readingList = filteredReadingLists.featuredList
        self.readingLists = filteredReadingLists.readingLists
      }
    })
  }
  
  private func loadReadingListContent(booksIds: [String], completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: booksIds, completion: {
      (success, resource, error) in
      defer {
        completion(success, error)
      }
      
      guard success, let books = resource?.filter({ ($0 is Book) }) else {
        return
      }
      
      self.featuredReadingListContent = books as? [Book]
    })
  }
  
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
  
  /// The first reading list will have it's books featured under the reading-list list
  /// The featured reading list is not included in the reading-list array
  private func filterReadingLists(readingListsIdentifiers: [String], resources: [Resource]) -> (featuredList: ReadingList?, readingLists: [ReadingList]) {
    var featuredReadingList: ReadingList? = nil
    var readingLists = [ReadingList]()
    for (index, readingListIdentifier) in readingListsIdentifiers.enumerated() {
      guard let resource = resources.filter({ $0.id == readingListIdentifier }).first as? ReadingList else {
        continue
      }
      
      if index == 0 {
        featuredReadingList = resource
      } else {
        readingLists.append(resource)
      }
    }
    return (featuredReadingList, readingLists)
  }
}


// MARK: Featured Content

extension BookStoreViewModel {
  var featuredContentNumberOfItems: Int {
    return 7
  }
  
  func featuredContentValues(for indexPath: IndexPath) -> (title: String?, image: UIImage?) {
    return ("Featuring Zouzou", #imageLiteral(resourceName: "Illustrtion"))
  }
}

// MARK: Bookwitty Suggests

extension BookStoreViewModel {
  var bookwittySuggestsNumberOfSections: Int {
    return 1
  }
  
  var bookwittySuggestsNumberOfItems: Int {
    return 4
  }
  
  func bookwittySuggestsValues(for indexPath: IndexPath) -> String {
    return "Reading list \(indexPath.row)"
  }
}

// MARK: Bookwitty Selection

extension BookStoreViewModel {
  var selectionNumberOfSection: Int {
    return 1
  }
  
  var selectionNumberOfItems: Int {
    return 5
  }
  
  func selectionValues(for indexPath: IndexPath) -> (image: UIImage?, bookTitle: String?, authorName: String?, productType: String?, price: String?) {
    return (#imageLiteral(resourceName: "Illustrtion"), "Harry potter and the phylosopher's stone and shafic hariri", "J.K. Rowling And Many Many Other authors and famous people", "Paperback", "150,000 L.L")
  }
}
