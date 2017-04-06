//
//  Price.swift
//  Bookwitty
//
//  Created by Marwan  on 4/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Price {
  var currency: String?
  let value: Float?
  
  init(for dictionary: [String : Any]?) {
    guard let dictionary = dictionary else {
      currency = nil
      value = nil
      return
    }
    let json = JSON(dictionary)
    currency = json["currency"].stringValue
    value = json["value"].floatValue
  }
  
  init(currency: String?, value: Float?) {
    self.currency = currency
    self.value = value
  }
  
  var formattedValue: String? {
    guard let currency = currency, let value = value, !currency.isEmpty else {
      return nil
    }
    let currencyFormatter = self.currencyFormatter
    currencyFormatter.currencyCode = currency
    return currencyFormatter.string(for: value)
  }
  
  private var currencyFormatter: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale.application
    numberFormatter.numberStyle = .currency
    return numberFormatter
  }
}
