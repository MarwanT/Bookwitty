//
//  Date+Utils.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension Date {
  static func formatter(_ format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale.application

    return formatter
  }
  
  static func from(_ string: String, formatter: DateFormatter? = nil) -> Date? {
    let dateFormatter = formatter != nil ? formatter! : Date.formatter()
    
    guard let date = dateFormatter.date(from: string) else {
      return nil
    }
    return date
  }
  
  func formatted(format: String = "MMM' 'dd' 'yyyy") -> String {
    let dateFormatter = Date.formatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}

extension NSDate {
  func formatted(format: String = "MMM' 'dd' 'yyyy") -> String {
    return (self as Date).formatted(format: format)
  }
}
