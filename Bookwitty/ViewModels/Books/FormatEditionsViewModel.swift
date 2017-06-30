//
//  FormatEditionsViewModel.swift
//  
//
//  Created by Marwan  on 6/30/17.
//
//

import Foundation

final class FormatEditionsViewModel {
  fileprivate var productForm: ProductForm?
  
  func initialize(with productForm: ProductForm) {
    self.productForm = productForm
  }
}
