//
//  SupplierInformation.swift
//  Bookwitty
//
//  Created by Marwan  on 4/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

class SupplierInformation: NSObject {
  var quantity: Int?
  var listPrice: Price?
  var price: Price?
  var userPrice: Price?
  var preferredPrice: Price? {
    if userPrice?.formattedValue != nil {
      return userPrice
    } else if price?.formattedValue != nil {
      return price
    } else {
      return listPrice
    }
  }
  
  override init() {
    super.init()
  }
  
  init(for dictionary: [String : Any]) {
    super.init()
    setValues(dictionary: dictionary)
  }
  
  private func setValues(dictionary: [String : Any]) {
    let json = JSON(dictionary)
    self.quantity = json["quantity"].intValue
    self.listPrice = Price(for: json["list-price"].dictionaryObject)
    self.price = Price(for: json["price"].dictionaryObject)
    self.userPrice = Price(for: json["user-price"].dictionaryObject)
  }
}
