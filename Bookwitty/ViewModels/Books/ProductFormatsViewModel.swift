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
  
  fileprivate var request: Cancellable? = nil
  
  fileprivate let maximumNumberOfPreferredFormats = 5
  
  func initialize(with currentBook: Book) {
    self.currentBook = currentBook
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
