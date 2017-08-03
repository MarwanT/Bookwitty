//
//  Environment.swift
//  Bookwitty
//
//  Created by Marwan  on 1/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct Environment {
  enum EnvironmentType: String {
    case mockLocal = "mockLocal"
    case mockServer = "mockServer"
    case development = "development"
    case staging = "staging"
    case production = "production"
  }
  
  static let current = Environment()
  
  let type: EnvironmentType
  let baseURL: URL
  let googleAnalyticsIdentifier: String
  let googleClientIdentifier: String
  let googleServerIdentifier: String
  
  let facebookLoginURL: URL
  let facebookLoginCallbackPath: String

  private init() {
    type = EnvironmentType(rawValue: AppKeys.shared.environmentString) ?? .mockServer
    switch type {
    default:
      baseURL = URL(string: AppKeys.shared.bookwittyServerBaseURLAbsoluteString)!
      googleAnalyticsIdentifier = AppKeys.shared.googleAnalyticsIdentifier

      //Note: this also exists in reverse in the info.plist as a url-type
      googleClientIdentifier = AppKeys.shared.googleClientIdentifier
      googleServerIdentifier = AppKeys.shared.googleServerIdentifier

      facebookLoginURL = URL(string: "account/auth/facebook", relativeTo: self.baseURL)!
      facebookLoginCallbackPath = "account/auth/facebook/callback"
    }
  }

  var shipementInfoURL: URL? {
    return URL(string: "/shipping?layout=mobile", relativeTo: self.baseURL)
  }
}
