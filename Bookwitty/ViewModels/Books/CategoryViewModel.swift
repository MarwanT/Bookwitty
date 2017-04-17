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
  
  var misfortuneNodeMode: MisfortuneNode.Mode? = nil
  
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
      // Set misfortune node mode
      if self.hasBanner || self.hasSubcategories || self.hasFeaturedContent || self.hasSelectionSection || self.hasBookwittySuggests {
        self.misfortuneNodeMode = nil
      } else {
        if let isReachable = AppManager.shared.reachability?.isReachable, !isReachable {
          self.misfortuneNodeMode = MisfortuneNode.Mode.noInternet
        } else {
          self.misfortuneNodeMode = MisfortuneNode.Mode.empty
        }
      }
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
      self.banner = collection.sections?.banner
      self.featuredContents = nil
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
  
  func featuredResource(for indexPath: IndexPath) -> ModelResource? {
    guard let resource = featuredContents?[indexPath.row] as? ModelResource else {
      return nil
    }
    return resource
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
  
  func suggestedReadingList(for indexPath: IndexPath) -> ModelResource? {
    let resource = readingLists?[indexPath.row]
    return resource
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
    return (URL(string: book.thumbnailImageUrl ?? ""), book.title, book.productDetails?.author, book.productDetails?.productFormat, book.supplierInformation?.preferredPrice?.formattedValue)
  }
  
  var books: [Book]? {
    return categoryBooks?.books
  }
  
  var booksLoadingMode: BooksTableViewController.DataLoadingMode? {
    guard let booksInfo = categoryBooks else {
      return nil
    }
    
    return BooksTableViewController.DataLoadingMode.server(nextPageURL: booksInfo.nextPage)
  }

  func book(for indexPath: IndexPath) -> Book? {
    guard let book = categoryBooks?.books?[indexPath.row] else {
      return nil
    }
    return book
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

