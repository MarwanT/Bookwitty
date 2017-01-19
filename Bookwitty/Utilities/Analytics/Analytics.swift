//
//  Analytics.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public final class Analytics {
  struct Event {
    var category: String
    var action: String
    var name: String
    var value: Double
  }
  
  public static let sharedInstance: Analytics = Analytics()
  private init() {
  }
  func send(event: Event) {
  }
  
  func send(screenName: String) {
  }
}
