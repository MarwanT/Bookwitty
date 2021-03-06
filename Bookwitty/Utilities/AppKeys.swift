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
  let apiKey: String
  let apiSecret: String
  let environmentString: String
  let bookwittyServerBaseURLAbsoluteString: String
  let googleAnalyticsIdentifier: String
  let iframelyKey: String
  
  static let shared = AppKeys()
  
  private init(keys: BookwittyKeys) {
    self.apiKey = keys.bookwittyAPIClientKey
    self.apiSecret = keys.bookwittyAPIClientSecret
    self.environmentString = keys.bookwittyEnvironment
    self.bookwittyServerBaseURLAbsoluteString = keys.bookwittyServerBaseURL
    self.googleAnalyticsIdentifier = keys.bookwittyGoogleAnalyticsIdentifier
    self.iframelyKey = keys.bookwittyIFramelyKey
  }
  
  private convenience init() {
    self.init(keys: BookwittyKeys())
  }
}
