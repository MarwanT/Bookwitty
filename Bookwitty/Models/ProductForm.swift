//
//  ProductForm.swift
//  Bookwitty
//
//  Created by Marwan  on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct ProductForm {
  var key: String
  var value: String
  
  init?() {
    self.init(key: "", value: "")
  }
  
  init?(key: String, value: String) {
    guard !key.isBlank else {
      return nil
    }
    self.key = key
    self.value = value
  }
}

extension ProductForm {
  /*
   *  The list of formats below is taken from the ONIX documentation here:
   *  https://www.medra.org/stdoc/onix-codelist-7.htm
   */
  private static let electronicProductForms = [
    "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AZ",
    "DA", "DB", "DC", "DD", "DE", "DF", "DG", "DH", "DI", "DJ", "DK", "DL", "DM",
    "DN", "DZ", "VA", "VB", "VC", "VD", "VE", "VF", "VG", "VH", "VI", "VJ", "VK",
    "VL", "VM", "VN", "VO", "VP", "VZ", "WW" ]
  
  var isElectronicFormat: Bool {
    return ProductForm.electronicProductForms.contains(self.key)
  }
  
  static func isElectronicFormat(_ key: String) -> Bool {
    return electronicProductForms.contains(key.uppercased())
  }
}
