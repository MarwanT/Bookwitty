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
    case server(nextPageURL: URL)
  }
  
  fileprivate var books: [Book]? = nil
  fileprivate var mode: DataLoadingMode? = nil
  
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
