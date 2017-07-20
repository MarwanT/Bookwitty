//
//  CustomAttributes.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class CuratedCollectionSectionsAttribute: Attribute {
  let sectionsString: String?
  
  init(sectionsString: String? = nil) {
    self.sectionsString = sectionsString
  }
}

class ProductDetailsAttribute: Attribute {
  let productDetails: [String : Any]?
  
  init(productDetails: [String : Any]? = nil) {
    self.productDetails = productDetails
  }
}

class SupplierInformationAttribute: Attribute {
  let supplierInformation: [String : Any]?
  
  init(supplierInformation: [String : Any]? = nil) {
    self.supplierInformation = supplierInformation
  }
}

class CountsAttribute: Attribute {
  let counts: [String : Any]?

  init(counts: [String : Any]? = nil) {
    self.counts = counts
  }
}

class PreferencesAttribute: Attribute {
  var preferences: [String : Any]?

  init(preferences: [String : Any]? = nil) {
    self.preferences = preferences
  }
}

class MediaAttribute: Attribute {
  let media: [String : Any]?

  init(media: [String : Any]? = nil) {
    self.media = media
  }
}
