//
//  BooksTableViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class BooksTableViewModel {
  enum DataLoadingMode {
    case local(paginator: Paginator)
    case server(nextPageURL: URL?)
  }
  
  fileprivate var books: [Book]? = nil
  fileprivate var mode: DataLoadingMode? = nil
  
  var isLoadingNextPage: Bool = false
  var didReachLastPage: Bool = false
  var hasNextPage: Bool {
    return !didReachLastPage
  }
  
  init(books: [Book]? = nil, loadingMode: DataLoadingMode? = nil) {
    self.books = books
    self.mode = loadingMode
  }
  
  var numberOfSections: Int {
    return (books?.count ?? 0) > 0 ? 1 : 0
  }
  
  func numberOfRows(for section: Int) -> Int {
    return books?.count ?? 0
  }
  
  func selectionValues(for indexPath: IndexPath) -> (imageURL: URL?, bookTitle: String?, authorName: String?, productType: String?, price: String?) {
    guard let book = books?[indexPath.row] else {
      return (nil, nil, nil, nil, nil)
    }
    return (URL(string: book.thumbnailImageUrl ?? ""), book.title, book.productDetails?.author, book.productDetails?.productFormat, book.supplierInformation?.displayPrice?.formattedValue)
  }
}


// MARK: - Paging Methods
extension BooksTableViewModel {
  func loadNextPage(completion: @escaping (_ success: Bool) -> Void) {
    guard let mode = mode else {
      completion(false)
      return
    }
    
    isLoadingNextPage = true
    
    switch mode {
    case .local(let paginator):
      guard let nextPageIds = paginator.nextPageIds(), nextPageIds.count > 0 else {
        self.didReachLastPage = true
        self.isLoadingNextPage = false
        completion(false)
        return
      }
      loadBooksForIds(identifiers: nextPageIds, completion: {
        (success, books) in
        var didLoadBooks = false
        defer {
          self.isLoadingNextPage = false
          completion(didLoadBooks)
        }
        
        guard success, let books = books else {
          return
        }
        self.books?.append(contentsOf: books)
        didLoadBooks = true
      })
    case .server(let nextPageURL):
      guard let url = nextPageURL else {
        self.didReachLastPage = true
        self.isLoadingNextPage = false
        completion(false)
        return
      }
      
      loadBooksForURL(nextPageURL: url, completion: {
        (success, books, url) in
        var didLoadBooks = false
        defer {
          self.isLoadingNextPage = false
          self.mode = .server(nextPageURL: url)
          completion(didLoadBooks)
        }
        
        guard success, let books = books else {
          return
        }
        self.books?.append(contentsOf: books)
        didLoadBooks = true
      })
    }
  }
  
  
  fileprivate func loadBooksForIds(identifiers: [String], completion: @escaping (_ success: Bool, _ books: [Book]?) -> Void) {
    _ = UserAPI.batch(identifiers: identifiers, completion: {
      (success, resources, error) in
      var books: [Book]? = nil
      defer {
        completion(success, books)
      }
      
      guard success, let definedResources = resources as? [Book] else {
        return
      }
      books = definedResources
    })
  }
  
  fileprivate func loadBooksForURL(nextPageURL: URL, completion: @escaping (_ success: Bool, _ books: [Book]?, _ nextPage: URL?) -> Void) {
    _ = GeneralAPI.nextPage(nextPage: nextPageURL, completion: {
      (success, resources, nextPage, error) in
      var books: [Book]? = nil
      defer {
        completion(success, books, nextPage)
      }
      
      guard success, let definedResources = resources as? [Book] else {
        return
      }
      books = definedResources
    })
  }
}
