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
    
    guard let year = components.year, let month = components.month, let weekOfYear = components.weekOfYear, let day = components.day, let hour = components.hour, let minute = components.minute, let second = components.second else {
      return result
    }
    
    if year >= 2 {
      result = "\(year) years ago"
    } else if year >= 1 {
      if numericDates {
        result = "1 year ago"
      } else {
        result = "Last year"
      }
    } else if month >= 2 {
      result = "\(month) months ago"
    } else if month >= 1 {
      if numericDates {
        result = "1 month ago"
      } else {
        result = "Last month"
      }
    } else if weekOfYear >= 2 {
      result = "\(weekOfYear) weeks ago"
    } else if weekOfYear >= 1 {
      if numericDates {
        result = "1 week ago"
      } else {
        result = "Last week"
      }
    } else if day >= 2 {
      result = "\(day) days ago"
    } else if day >= 1 {
      if numericDates {
        result = "1 day ago"
      } else {
        result = "Yesterday"
      }
    } else if hour >= 2 {
      result = "\(hour) hours ago"
    } else if hour >= 1 {
      if numericDates {
        result = "1 hour ago"
      } else {
        result = "An hour ago"
      }
    } else if minute >= 2 {
      result = "\(minute) minutes ago"
    } else if minute >= 1 {
      if numericDates {
        result = "1 minute ago"
      } else {
        result = "A minute ago"
      }
    } else if second >= 0 && numericDates {
      result = "\(second) seconds ago"
    } else {
      result = "Just now"
    }
    
    return result
  }
}
