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
  
  func relativelyFormatted() -> String {
    let dateFormatter = Date.formatter()
    return dateFormatter.timeSince(from: self, numericDates: true)
  }
}

extension NSDate {
  func formatted(format: String = "MMM' 'dd' 'yyyy") -> String {
    return (self as Date).formatted(format: format)
  }
}


extension DateFormatter {
  /**
   Formats a date as the time since that date (e.g., “Last week, yesterday, etc.”).
   
   - Parameter from: The date to process.
   - Parameter numericDates: Determines if we should return a numeric variant, e.g. "1 month ago" vs. "Last month".
   
   - Returns: A string with formatted `date`.
   */
  func timeSince(from: Date, numericDates: Bool = false) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(from)
    let latest = earliest == now ? from : now
    let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest)
    
    var result = ""
    
    if components.year! >= 2 {
      result = "\(components.year!) years ago"
    } else if components.year! >= 1 {
      if numericDates {
        result = "1 year ago"
      } else {
        result = "Last year"
      }
    } else if components.month! >= 2 {
      result = "\(components.month!) months ago"
    } else if components.month! >= 1 {
      if numericDates {
        result = "1 month ago"
      } else {
        result = "Last month"
      }
    } else if components.weekOfYear! >= 2 {
      result = "\(components.weekOfYear!) weeks ago"
    } else if components.weekOfYear! >= 1 {
      if numericDates {
        result = "1 week ago"
      } else {
        result = "Last week"
      }
    } else if components.day! >= 2 {
      result = "\(components.day!) days ago"
    } else if components.day! >= 1 {
      if numericDates {
        result = "1 day ago"
      } else {
        result = "Yesterday"
      }
    } else if components.hour! >= 2 {
      result = "\(components.hour!) hours ago"
    } else if components.hour! >= 1 {
      if numericDates {
        result = "1 hour ago"
      } else {
        result = "An hour ago"
      }
    } else if components.minute! >= 2 {
      result = "\(components.minute!) minutes ago"
    } else if components.minute! >= 1 {
      if numericDates {
        result = "1 minute ago"
      } else {
        result = "A minute ago"
      }
    } else if components.second! >= 0 && numericDates {
      result = "\(components.second!) seconds ago"
    } else {
      result = "Just now"
    }
    
    return result
  }
}
