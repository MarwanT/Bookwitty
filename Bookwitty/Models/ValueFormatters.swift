//
//  ValueFormatters.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class CuratedCollectionSectionsValueFormatter: ValueFormatter {
  typealias FormattedType = [String : Any]
  typealias UnformattedType = CuratedCollectionSections
  typealias AttributeType = CuratedCollectionSectionsAttribute
  
  func unformatValue(_ value: [String : Any], forAttribute: CuratedCollectionSectionsAttribute) -> CuratedCollectionSections {
    return CuratedCollectionSections(for: value)
  }
  
  func formatValue(_ value: CuratedCollectionSections, forAttribute: CuratedCollectionSectionsAttribute) -> [String : Any] {
    // TODO: Implement this
    return ["" : ""]
  }
}

class ProductDetailsValueFormatter: ValueFormatter {
  typealias FormattedType = [String : Any]
  typealias UnformattedType = ProductDetails
  typealias AttributeType = ProductDetailsAttribute
  
  func unformatValue(_ value: [String : Any], forAttribute: ProductDetailsAttribute) -> ProductDetails {
    return ProductDetails(for: value)
  }
  
  func formatValue(_ value: ProductDetails, forAttribute: ProductDetailsAttribute) -> [String : Any] {
    // TODO: Implement this
    return ["" : ""]
  }
}

class SupplierInformationValueFormatter: ValueFormatter {
  typealias FormattedType = [String : Any]
  typealias UnformattedType = SupplierInformation
  typealias AttributeType = SupplierInformationAttribute
  
  func unformatValue(_ value: [String : Any], forAttribute: SupplierInformationAttribute) -> SupplierInformation {
    return SupplierInformation(for: value)
  }
  
  func formatValue(_ value: SupplierInformation, forAttribute: SupplierInformationAttribute) -> [String : Any] {
    // TODO: Implement this
    return ["" : ""]
  }
}
