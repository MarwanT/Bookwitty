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
  fileprivate var curatedCollection: CuratedCollection? = nil
  fileprivate var featuredContents: [ModelCommonProperties]? = nil
  fileprivate var featuredReadingListContent: (fetchedBooks: [Book]?, booksIds: [String])? = nil
  fileprivate var readingLists: [ReadingList]? = nil
  fileprivate var banner: Banner? = nil
  
  let maximumNumberOfBooks = 3
  let maximumNumberOfReadingLists = 3
  
  let pageSize: Int = 10
  
  var request: Cancellable?
  
  var dataLoaded: ((_ finished: Bool) -> Void)? = nil
  
  func clearData() {
    self.curatedCollection = nil
    self.banner = nil
    self.featuredContents = nil
    self.featuredReadingListContent = nil
    self.readingLists = nil
  }
  
  func loadData(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    request = loadCuratedContent(completion: {
      (success, identifiers, error) in
      guard success else {
        self.request = nil
        completion(false, error)
        return
      }
      
      // If data needs to be viewed partially here even before retrieving
      // content details, a block trigering a change in the vc should be called here.
      self.dataLoaded?(false)
      
      guard let identifiers = identifiers, identifiers.count > 0 else {
        self.request = nil
        completion(true, nil)
        return
      }
      
      self.request = self.loadContentDetails(identifiers: identifiers, completion: {
        (success, readingList, error) in
        guard success, let booksIds = readingList?.postsRelations?.filter({ $0.type == Book.resourceType }).flatMap({ $0.id }) else {
          self.request = nil
          completion(success, error)
          return
        }
        
        // If data needs to be viewed partially here even before retrieving
        // content details, a block trigering a change in the vc should be called here.
        self.dataLoaded?(false)
        
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
      self.banner = collection.sections?.banner
      self.featuredContents = nil
      self.featuredReadingListContent = nil
      self.readingLists = nil
      
      guard let sections = collection.sections  else {
        completion(true, nil, nil)
        return
      }
      
      if let featuredContent = sections.featuredContent {
        identifiers += featuredContent
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
        DataManager.shared.update(resources: self.readingLists ?? [])
      }
    })
  }
  
  private func loadReadingListContent(booksIds: [String], completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let selectedIds = Array(booksIds.prefix(pageSize))
    
    return UserAPI.batch(identifiers: selectedIds, completion: {
      (success, resource, error) in
      defer {
        completion(success, error)
      }
      
      guard success, let books = resource?.filter({ ($0 is Book) }) as? [Book] else {
        return
      }
      
      self.featuredReadingListContent = (books, booksIds)
    })
  }
  
  private func filterFeaturedContents(featuredContents: [String], resources: [Resource]) -> [ModelCommonProperties] {
    var filteredContent = [ModelCommonProperties]()

    for postId in featuredContents {
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
    for readingListIdentifier in readingListsIdentifiers {
      guard let resource = resources.filter({ $0.id == readingListIdentifier }).first as? ReadingList else {
        continue
      }
      
      if featuredReadingList == nil {
        featuredReadingList = resource
      } else {
        readingLists.append(resource)
      }
    }
    return (featuredReadingList, readingLists)
  }
}

// MARK: Banner

extension BookStoreViewModel {
  var hasBanner: Bool {
    return banner != nil
  }
  
  var bannerImageURL: URL? {
    return banner?.imageUrl
  }
  
  var bannerTitle: String? {
    return banner?.caption
  }
  
  var bannerSubtitle: String? {
    return nil
  }
}

// MARK: Featured Content

extension BookStoreViewModel {
  var hasFeaturedContent : Bool {
    return featuredContentNumberOfItems > 0
  }
  
  var featuredContentNumberOfItems: Int {
    return featuredContents?.count ?? 0
  }
  
  func featuredContentValues(for indexPath: IndexPath) -> (title: String?, imageURL: URL?) {
    guard let featuredContent = featuredContents?[indexPath.row] else {
      return (nil, nil)
    }
    return (featuredContent.title, URL(string: (featuredContent.thumbnailImageUrl ?? "")))
  }
  
  func featuredResource(for indexPath: IndexPath) -> ModelResource? {
    guard let resource = featuredContents?[indexPath.row] as? ModelResource else {
      return nil
    }
    return resource
  }
}

// MARK: Categories

extension BookStoreViewModel {
  var hasCategories: Bool {
    return true
  }
}

// MARK: Bookwitty Suggests

extension BookStoreViewModel {
  var hasBookwittySuggests: Bool {
    return bookwittySuggestsNumberOfSections != 0
  }
  
  var bookwittySuggestsNumberOfSections: Int {
    return (readingLists?.count ?? 0) > 0 ? 1 : 0
  }
  
  var bookwittySuggestsNumberOfItems: Int {
    guard let readingListsCount = readingLists?.count else {
      return 0
    }
    return readingListsCount < maximumNumberOfReadingLists ? readingListsCount : maximumNumberOfReadingLists
  }
  
  func bookwittySuggestsValues(for indexPath: IndexPath) -> String {
    guard let readingListTitle = readingLists?[indexPath.row].title else {
      return ""
    }
    return readingListTitle
  }
  
  func suggestedReadingList(for indexPath: IndexPath) -> ModelResource? {
    let resource = readingLists?[indexPath.row]
    return resource
  }
}

// MARK: Bookwitty Selection

extension BookStoreViewModel {
  var hasSelectionSection: Bool {
    return selectionNumberOfSection > 0
  }
  
  var selectionNumberOfSection: Int {
    return (featuredReadingListContent?.fetchedBooks?.count ?? 0) > 0 ? 1 : 0
  }
  
  var selectionNumberOfItems: Int {
    guard let booksCount = featuredReadingListContent?.fetchedBooks?.count else {
      return 0
    }
    return booksCount < maximumNumberOfBooks ? booksCount : maximumNumberOfBooks
  }
  
  func selectionValues(for indexPath: IndexPath) -> (imageURL: URL?, bookTitle: String?, authorName: String?, productType: String?, price: String?) {
    guard let book = featuredReadingListContent?.fetchedBooks?[indexPath.row] else {
      return (nil, nil, nil, nil, nil)
    }
    return (URL(string: book.thumbnailImageUrl ?? ""), book.title, book.productDetails?.author, book.productDetails?.productForm?.value, book.supplierInformation?.preferredPrice?.formattedValue)
  }
  
  func book(for indexPath: IndexPath) -> Book? {
    guard let book = featuredReadingListContent?.fetchedBooks?[indexPath.row] else {
      return nil
    }
    return book
  }
  
  var books: [Book]? {
    return featuredReadingListContent?.fetchedBooks
  }
  
  var booksLoadingMode: BooksTableViewController.DataLoadingMode? {
    guard let books = featuredReadingListContent else {
      return nil
    }
    let paginator = Paginator(ids: books.booksIds, pageSize: pageSize, startPage: 1)
    return .local(paginator: paginator)
  }

  var selections: [ReadingList] {
    return readingLists ?? []
  }
}

// MARK: - Introductory Banner Logic
extension BookStoreViewModel {
  var shouldDisplayIntroductoryBanner: Bool {
    get {
      return GeneralSettings.sharedInstance.shouldDisplayBookStoreIntroductoryBanner
    }
    set {
      GeneralSettings.sharedInstance.shouldDisplayBookStoreIntroductoryBanner = newValue
    }
  }
}
