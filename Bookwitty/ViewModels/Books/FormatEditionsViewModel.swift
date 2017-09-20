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
  fileprivate var nextPageURL: URL? = nil
  
  fileprivate var editions: [FormatEdition] = []
  
  func initialize(initialProductIdentifier: String, productForm: ProductForm) {
    self.initialProductIdentifier = initialProductIdentifier
    self.productForm = productForm
  }
}

extension FormatEditionsViewModel {
  var numberOfSections: Int {
    return 1
  }
  
  func numberOfRows(in section: Int) -> Int {
    return editions.count
  }
  
  func valueForRow(at indexPath: IndexPath) -> (id: String?, description: String?, formattedPrice: String?)? {
    let editionValues = editions[indexPath.item]
    return (editionValues.id, editionValues.form?.value, editionValues.price?.formattedValue)
  }
  
  func analyticsValues(for indexPath: IndexPath) -> (productTitle: String, format: String, date: String) {
    let editionValues = editions[indexPath.item]
    return (editionValues.title ?? "", editionValues.form?.value ?? "", editionValues.publishedAt?.formatted() ?? "")
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
      self.nextPageURL = nextURL
    })
  }
  
  func loadNextPage(completion: @escaping (_ success: Bool, _ error: FormatEditionsError?) -> Void) {
    guard let url = nextPageURL else {
      completion(false, nil)
      return
    }
    
    request?.cancel()
    request = GeneralAPI.nextPage(nextPage: url, completion: { (success, resources, url, apiError) in
      var error = apiError != nil ? FormatEditionsError.api(apiError) : nil
      defer {
        self.request = nil
        completion(success, error)
      }
      
      guard success, let resources = resources else {
        return
      }
      self.editions.append(contentsOf: self.values(resources: resources))
      self.nextPageURL = url
    })
  }
  
  var isLoadingData: Bool {
    return request != nil
  }
  
  var hasNextPage: Bool {
    return nextPageURL != nil
  }
  
  private func values(resources: [ModelResource]) -> [FormatEdition] {
    guard let books = resources as? [Book] else {
      return []
    }
    
    var editions = books.flatMap({ (book) -> FormatEdition? in
      guard let id: String = book.id else {
        return nil
      }

      let title: String? = book.title
      let description: String = editionDescription(for: book)
      let form: ProductForm? = book.productDetails?.productForm
      let price = book.preferredPrice
      let publishedAt: Date? = book.productDetails?.publishedAt
      return (id, title, description, price, form, publishedAt)
    })
    
    // Sort editions by the cheapest, and the ones with no price come last
    editions.sort(by: {
      ($0.price?.value ?? Float.infinity) < ($1.price?.value ?? Float.infinity)
    })
    
    return editions
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
  typealias FormatEdition = (id: String, title: String?, description: String, price: Price?, form: ProductForm?, publishedAt: Date?)
  
  enum FormatEditionsError {
    case api(BookwittyAPIError?)
    case unidentified
  }
}
