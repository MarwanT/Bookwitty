//
//  FormatEditionsViewModel.swift
//  
//
//  Created by Marwan  on 6/30/17.
//
//

import Foundation
import Moya

final class FormatEditionsViewModel {
  fileprivate var initialProductIdentifier: String?
  fileprivate var productForm: ProductForm?
  
  fileprivate var request: Cancellable? = nil
  
  fileprivate var editions: [FormatEdition] = []
  
  func initialize(initialProductIdentifier: String, productForm: ProductForm) {
    self.initialProductIdentifier = initialProductIdentifier
    self.productForm = productForm
  }
}

extension FormatEditionsViewModel {
  func loadData(completion: @escaping (_ success: Bool, _ error: FormatEditionsError?) -> Void) {
    guard let initialProductIdentifier = initialProductIdentifier, let formatId = productForm?.key else {
      request = nil
      completion(false, nil)
      return
    }
    
    request?.cancel()
    request = ContentAPI.editions(contentIdentifier: initialProductIdentifier, formats: [formatId], completion: {
      (success, resources, nextURL, apiError) in
      var error = apiError != nil ? FormatEditionsError.api(apiError) : nil
      defer {
        self.request = nil
        completion(success, error)
      }
      
      guard success, let resources = resources else {
        error = FormatEditionsError.unidentified
        return
      }
      
      self.editions.removeAll()
      self.editions.append(contentsOf: self.values(resources: resources))
    })
  }
  
  private func values(resources: [ModelResource]) -> [FormatEdition] {
    guard let books = resources as? [Book] else {
      return []
    }
    
    return books.flatMap({
      let id: String? = $0.id
      let description: String = editionDescription(for: $0)
      let price = $0.preferredPrice
      return (id, description, price) as? FormatEdition
    }).sorted(by: {
      ($0.price?.value ?? 0) < ($1.price?.value ?? 0)
    })
  }
  
  private func editionDescription(for book: Book) -> String {
    var description = ""
    var currentSeparator = ""
    let separator = ", "
    
    if let formatString = book.productDetails?.productFormat, !formatString.isBlank {
      description += "\(formatString)"
      currentSeparator = separator
    }
    
    if let formatedDate = book.productDetails?.publishedAt?.formatted().capitalized, !formatedDate.isBlank {
      description += "\(currentSeparator)\(formatedDate)"
    }
    
    return description
  }
}

extension FormatEditionsViewModel {
  typealias FormatEdition = (id: String, description: String, price: Price?)
  
  enum FormatEditionsError {
    case api(BookwittyAPIError?)
    case unidentified
  }
}
