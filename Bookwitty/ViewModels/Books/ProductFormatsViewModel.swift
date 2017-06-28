//
//  ProductFormatsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 6/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class ProductFormatsViewModel {
  fileprivate var preferredFormats: [PreferredFormatValues] = []
  fileprivate var availableFormats: [AvailableFormatValues] = []
  fileprivate var totalNumberOfEditions: Int = 0
  
}

extension ProductFormatsViewModel {
  typealias PreferredFormatValues = (id: String, form: ProductForm, price: Price?, isSelected: Bool)
  typealias AvailableFormatValues = (form: ProductForm, numberOfEditions: Int)
}
