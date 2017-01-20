//
//  Keys.swift
//  Bookwitty
//
//  Created by Marwan  on 1/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Keys

internal final class AppKeys {
  let googleAnalyticsIdentifier: String
  
  static let shared = AppKeys()
  
  private init(googleAnalyticsIdentifier: String) {
    self.googleAnalyticsIdentifier = googleAnalyticsIdentifier
  }
  
  private init(keys: BookwittyKeys) {
    self.googleAnalyticsIdentifier = keys.bookwittyGoogleAnalyticsIdentifier
  }
  
  private convenience init() {
    self.init(keys: BookwittyKeys())
  }
}
