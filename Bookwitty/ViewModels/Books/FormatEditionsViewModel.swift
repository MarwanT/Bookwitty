//
//  FormatEditionsViewModel.swift
//  
//
//  Created by Marwan  on 6/30/17.
//
//

import Foundation

final class FormatEditionsViewModel {
  fileprivate var initialProductIdentifier: String?
  fileprivate var productForm: ProductForm?
  
  fileprivate var editions: [FormatEdition] = []
  
  func initialize(initialProductIdentifier: String, productForm: ProductForm) {
    self.initialProductIdentifier = initialProductIdentifier
    self.productForm = productForm
  }
}

extension FormatEditionsViewModel {
  private func values(resources: [ModelResource]) -> [FormatEdition] {
    guard let books = resources as? [Book] else {
      return []
    }
    
    return books.flatMap({
      let id: String? = $0.id
      let description: String = editionDescription(for: $0)
      let price = $0.preferredPrice
      return (id, description, price) as? FormatEdition
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
