//
//  Date+Utils.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension Date {
  static func formatDate(date: NSDate?, dateStyle dStyle: DateFormatter.Style = .long, timeStyle tStyle: DateFormatter.Style = .none) -> String {
    guard let nsDate = date else {
      return ""
    }

    let date = nsDate as Date
    return date.formatDate(dateStyle: dStyle, timeStyle: tStyle)
  }

  func formatDate(dateStyle dStyle: DateFormatter.Style = .long, timeStyle tStyle: DateFormatter.Style = .none) -> String {
    return DateFormatter.localizedString(from: self, dateStyle: dStyle, timeStyle: tStyle)
  }
}
