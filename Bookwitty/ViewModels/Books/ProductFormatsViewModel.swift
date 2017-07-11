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
    }
  }
  
  /// Returns nil when section header should not be visible
  func sectionValues(for section: Int) -> Any? {
    guard !isLoadingData else {
      return nil
    }
    
    guard let section = ProductFormatsViewController.Section(rawValue: section) else {
      return nil
    }
    
    switch section {
    case .preferredFormats:
      return Strings.choose_format()
    case .availableFormats:
      guard availableFormats.count > 0 else {
        return nil
      }
      
      if isListOfAvailableFormatsExpanded {
        return (Strings.hide_formats_and_editions(),
                CollapsableTableViewSectionHeaderView.Mode.expanded)
      } else {
        return (Strings.view_formats_and_editions(number: totalNumberOfEditions),
                CollapsableTableViewSectionHeaderView.Mode.collapsed)
      }
    default:
      return nil
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
    
    preferredFormats[indexPath.item].isSelected = true
  }
  
  func deselectPreferredFormat() {
    for index in 0..<preferredFormats.count {
      // Deselect Currently selected
      if preferredFormats[index].isSelected {
        preferredFormats[index].isSelected = false
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
  
  fileprivate func values(numberOfEditionsPerFormat: [String: Int], totalNumberOfEditions: Int) {
    let (formats, numberOfTrimmedEditions) = validateAndTrimAvailableFormats(numberOfEditionsPerFormat: numberOfEditionsPerFormat)
    
    self.availableFormats = formats.flatMap { (key, value)  -> ProductFormatsViewModel.AvailableFormatValues? in
      let productForm = BookFormatMapper.shared.productForm(for: key)
      return (productForm, value)
    }

    self.totalNumberOfEditions = totalNumberOfEditions - numberOfTrimmedEditions
  }
  
  fileprivate func validateAndTrimPreferredBooks(books: [Book]) -> [Book] {
    var pickedBooks: [Book] = []
    
    // filter audio formats
    pickedBooks = books.filter({ !($0.productDetails?.isElectronicFormat ?? false) })
    
    // Do not exceed maximum amount of preferred books
    let maxIndex = min(maximumNumberOfPreferredFormats, pickedBooks.count)
    pickedBooks = Array(pickedBooks[0..<maxIndex])
    
    // Make sure that the current book is among picked formats
    if let currentBook = currentBook, !pickedBooks.contains(where: { $0.id == currentBook.id }) {
      if let index = pickedBooks.index(where: {
        $0.productDetails?.productForm?.key == currentBook.productDetails?.productForm?.key
      }) {
        pickedBooks.remove(at: index)
        pickedBooks.insert(currentBook, at: 0)
      }
    }
    return pickedBooks
  }
  
  fileprivate func validateAndTrimAvailableFormats(numberOfEditionsPerFormat: [String: Int]) -> (formats: [String: Int], numberOfTrimmedEditions: Int) {
    var pickedFormats: [String : Int] = [:]
    var totalEditionsTrimmed: Int = 0
    numberOfEditionsPerFormat.forEach { (key, value) in
      guard !ProductForm.isElectronicFormat(key) else {
        totalEditionsTrimmed += value
        return
      }
      pickedFormats[key] = value
    }
    return (pickedFormats, totalEditionsTrimmed)
  }
  
  var productId: String? {
    return currentBook?.id
  }
  
  var productTitle: String? {
    return currentBook?.title
  }
  
  func toggleSection() {
    isListOfAvailableFormatsExpanded = !isListOfAvailableFormatsExpanded
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
        self.request = nil
        completion(success, error)
      }
      
      guard success, let books = books, let metadata = metadata else {
        return
      }
      
      // Set preferred formats
      self.preferredFormats = self.values(books: books)
      
      // Set available formats and the number of editions
      self.values(numberOfEditionsPerFormat: metadata.numberOfEditionsPerFormat, totalNumberOfEditions: metadata.totalEditions)
    })
  }
  
  var isLoadingData: Bool {
    return request != nil
  }
}

extension ProductFormatsViewModel {
  typealias PreferredFormatValues = (id: String, form: ProductForm, price: Price?, isSelected: Bool)
  typealias AvailableFormatValues = (form: ProductForm, numberOfEditions: Int)
  
  typealias AvailableFormatHeaderValues = (title: String, mode: CollapsableTableViewSectionHeaderView.Mode)
  
  enum ProductFormatsError {
    case api(BookwittyAPIError?)
    case unidentified
  }
}
