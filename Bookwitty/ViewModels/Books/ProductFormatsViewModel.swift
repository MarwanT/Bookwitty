//
//  ProductFormatsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 6/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class ProductFormatsViewModel {
  fileprivate var currentBook: Book? = nil
  fileprivate var preferredFormats: [PreferredFormatValues] = []
  fileprivate var availableFormats: [AvailableFormatValues] = []
  fileprivate var totalNumberOfEditions: Int = 0
  
  var isListOfAvailableFormatsExpanded: Bool = false
  
  fileprivate var request: Cancellable? = nil
  
  fileprivate let maximumNumberOfPreferredFormats = 5
  
  func initialize(with currentBook: Book) {
    self.currentBook = currentBook
  }
  
  var numberOfSections: Int {
    return ProductFormatsViewController.Section.numberOfSections
  }
  
  func numberOfRows(in section: Int) -> Int {
    guard let section = ProductFormatsViewController.Section(rawValue: section) else {
      return 0
    }
    
    switch section {
    case .preferredFormats:
      return preferredFormats.count
    case .availableFormats:
      return isListOfAvailableFormatsExpanded ? availableFormats.count : 0
    case .activityIndicator:
      return 0
    }
  }
  
  func values(for indexPath: IndexPath) -> Any? {
    guard let section = ProductFormatsViewController.Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .preferredFormats:
      return preferredFormats[indexPath.item]
    case .availableFormats:
      return availableFormats[indexPath.item]
    default:
      return nil
    }
  }
  
  func selectPreferredFormat(_ indexPath: IndexPath) {
    guard let section = ProductFormatsViewController.Section(rawValue: indexPath.section) else {
      return
    }
    guard case ProductFormatsViewController.Section.preferredFormats = section else {
      return
    }
    
    for index in 0..<preferredFormats.count {
      // Deselect Currently selected
      if preferredFormats[index].isSelected {
        preferredFormats[index].isSelected = false
      }
      // Select new value
      if index == indexPath.item {
        preferredFormats[index].isSelected = true
      }
    }
  }
  
  fileprivate func values(books: [Book]) -> [PreferredFormatValues] {
    let validatedBooks = validateAndTrimPreferredBooks(books: books)
    
    var valuesArray = [PreferredFormatValues]()
    validatedBooks.forEach { (book) in
      guard let id = book.id, let productForm = book.productDetails?.productForm else {
        return
      }
      valuesArray.append((id, productForm, book.preferredPrice, id == currentBook?.id))
    }
    return valuesArray
  }
  
  fileprivate func values(numberOfEditionsPerFormat: [String: Int]) -> [AvailableFormatValues] {
    var valuesArray = [AvailableFormatValues]()
    numberOfEditionsPerFormat.forEach { (key, value) in
      guard let productForm = BookFormatMapper.shared.productForm(for: key) else {
        return
      }
      valuesArray.append((productForm, value))
    }
    return valuesArray
  }
  
  fileprivate func validateAndTrimPreferredBooks(books: [Book]) -> [Book] {
    let maxIndex = min(maximumNumberOfPreferredFormats, books.count)
    var pickedBooks = Array(books[0..<maxIndex])
    if let currentBook = currentBook, !pickedBooks.contains(currentBook) {
      pickedBooks.removeLast()
      pickedBooks.insert(currentBook, at: 0)
    }
    return pickedBooks
  }
}

extension ProductFormatsViewModel {
  func loadData(completion: @escaping (_ success: Bool, _ error: ProductFormatsError?) -> Void) {
    guard let currentBookId = currentBook?.id else {
      completion(false, ProductFormatsViewModel.ProductFormatsError.unidentified)
      return
    }
    
    request?.cancel()
    request = ContentAPI.preferredFormats(identifier: currentBookId, completion: {
      (success, books, metadata, apiError) in
      var error = apiError != nil ? ProductFormatsError.api(apiError) : nil
      defer {
        completion(success, error)
      }
      
      guard success, let books = books, let metadata = metadata else {
        return
      }
      
      // Set preferred formats
      self.preferredFormats = self.values(books: books)
      
      // Set available formats
      self.availableFormats = self.values(numberOfEditionsPerFormat: metadata.numberOfEditionsPerFormat)
      
      // Set the number of editions
      self.totalNumberOfEditions = metadata.totalEditions
    })
  }
}

extension ProductFormatsViewModel {
  typealias PreferredFormatValues = (id: String, form: ProductForm, price: Price?, isSelected: Bool)
  typealias AvailableFormatValues = (form: ProductForm, numberOfEditions: Int)
  
  enum ProductFormatsError {
    case api(BookwittyAPIError?)
    case unidentified
  }
}
