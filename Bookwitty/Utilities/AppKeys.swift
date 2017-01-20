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
  let environmentString: String
  let bookwittyServerBaseURLAbsoluteString: String
  let googleAnalyticsIdentifier: String
  
  static let shared = AppKeys()
  
  private init(keys: BookwittyKeys) {
    self.environmentString = keys.bookwittyEnvironment
    self.bookwittyServerBaseURLAbsoluteString = keys.bookwittyGoogleAnalyticsIdentifier
    self.googleAnalyticsIdentifier = keys.bookwittyGoogleAnalyticsIdentifier
  }
  
  private convenience init() {
    self.init(keys: BookwittyKeys())
  }
}
