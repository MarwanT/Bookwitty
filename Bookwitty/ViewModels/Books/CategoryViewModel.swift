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
  fileprivate var categoryBooks: (books: [Book]?, nextPage: URL?)? = nil
  fileprivate var readingLists: [ReadingList]? = nil
  fileprivate var banner: Banner? = nil
  
  let maximumNumberOfBooks: Int = 3
  
  var category: Category! = nil
  
  var subcategories: [Category]? {
    return category.subcategories
  }
  
  var viewControllerTitle: String {
    return category.value ?? Strings.category()
  }
  
  // MARK: API Calls
  
  var curatedContentRequest: Cancellable? = nil
  var categoryBooksRequest: Cancellable? = nil
  
  func loadData(completion: @escaping (_ success: Bool, _ error: [BookwittyAPIError?]?) -> Void) {
    guard let categoryIdentifier = category.key else {
      completion(false, nil)
      return
    }
    
    var curatedAPISuccess: Bool = false
    var categoryBooksAPISuccess: Bool = false
    var curatedAPIError: BookwittyAPIError? = nil
    var categoryBooksAPIError: BookwittyAPIError? = nil
    
    let group = DispatchGroup()
    
    group.enter()
    curatedContentRequest = loadCuratedContent(categoryIdentifier: categoryIdentifier, completion: {
      (success, identifiers, error) in
      guard success, let identifiers = identifiers, identifiers.count > 0 else {
        self.curatedContentRequest = nil
        curatedAPISuccess = success
        curatedAPIError = error
        group.leave()
        return
      }
      
      self.curatedContentRequest = self.loadContentDetails(identifiers: identifiers, completion: {
        (success, error) in
        self.curatedContentRequest = nil
        curatedAPISuccess = success
        curatedAPIError = error
        group.leave()
      })
    })
    
    
    group.enter()
    categoryBooksRequest = loadCategoryBooks(categoryIdentifier: categoryIdentifier, completion: {
      (success, error) in
      self.categoryBooksRequest = nil
      categoryBooksAPISuccess = success
      categoryBooksAPIError = error
      group.leave()
    })
    
    
    group.notify(queue: DispatchQueue.main) { 
      completion(curatedAPISuccess && categoryBooksAPISuccess, [curatedAPIError, categoryBooksAPIError])
    }
  }

  private func loadCuratedContent(categoryIdentifier: String, completion: @escaping (_ success: Bool, _ identifiers: [String]? , _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    curatedCollection = nil
    featuredContents = nil
    readingLists = nil
    banner = nil
    
    return CategoryAPI.categoryCuratedContent(categoryIdentifier: categoryIdentifier, completion: {
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
  
  private func loadContentDetails(identifiers: [String], completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return UserAPI.batch(identifiers: identifiers, completion: {
      (success, resources, error) in
      defer {
        completion(success, error)
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
  
  private func loadCategoryBooks(categoryIdentifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    categoryBooks = nil
    
    return SearchAPI.search(filter: (nil, [categoryIdentifier]), page: nil, completion: {
      (success, resources, nextPage, error) in
      defer {
        completion(success, error)
      }
      
      guard success, let books = resources as? [Book] else {
        return
      }
      
      self.categoryBooks = (books, nextPage)
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


// MARK: - Banner

extension CategoryViewModel {
  var hasBanner: Bool {
    return true
  }
  
  var bannerImageURL: URL? {
    return URL(string: "http://fm.cnbc.com/applications/cnbc.com/resources/img/editorial/2013/09/12/101029496--sites-default-files-images-101029496-3176173-1748009911-hp.jp-1.jpg?v=1474281478")
  }
  
  var bannerTitle: String? {
    return "Bookwitty's Finest"
  }
  
  var bannerSubtitle: String? {
    return "The perfect list for everyone on your list"
  }
}


// MARK: - Featured Content

extension CategoryViewModel {
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
}


// MARK: - Bookwitty Suggests

extension CategoryViewModel {
  var hasBookwittySuggests: Bool {
    return bookwittySuggestsNumberOfSections != 0
  }
  
  var bookwittySuggestsNumberOfSections: Int {
    return (readingLists?.count ?? 0) > 0 ? 1 : 0
  }
  
  var bookwittySuggestsNumberOfItems: Int {
    return readingLists?.count ?? 0
  }
  
  func bookwittySuggestsValues(for indexPath: IndexPath) -> String {
    guard let readingListTitle = readingLists?[indexPath.row].title else {
      return ""
    }
    return readingListTitle
  }
}


// MARK: - Bookwitty Selection

extension CategoryViewModel {
  var hasSelectionSection: Bool {
    return selectionNumberOfSection > 0
  }
  
  var selectionNumberOfSection: Int {
    return (categoryBooks?.books?.count ?? 0) > 0 ? 1 : 0
  }
  
  var selectionNumberOfItems: Int {
    guard let booksCount = categoryBooks?.books?.count else {
      return 0
    }
    return booksCount < maximumNumberOfBooks ? booksCount : maximumNumberOfBooks
  }
  
  func selectionValues(for indexPath: IndexPath) -> (imageURL: URL?, bookTitle: String?, authorName: String?, productType: String?, price: String?) {
    guard let book = categoryBooks?.books?[indexPath.row] else {
      return (nil, nil, nil, nil, nil)
    }
    return (URL(string: book.thumbnailImageUrl ?? ""), book.title, book.productDetails?.author, book.productDetails?.productFormat, book.supplierInformation?.displayPrice?.formattedValue)
  }
  
  var booksTableViewModel: BooksTableViewModel {
    guard let booksInfo = categoryBooks else {
      return BooksTableViewModel()
    }
    
    let viewModel = BooksTableViewModel(books: booksInfo.books, loadingMode:
      BooksTableViewModel.DataLoadingMode.server(nextPageURL: booksInfo.nextPage))
    return viewModel
  }
}


// MARK: - Subcategories

extension CategoryViewModel {
  var hasSubcategories: Bool {
    if let subcategories = category.subcategories, subcategories.count > 0 {
      return true
    } else {
      return false
    }
  }
}

