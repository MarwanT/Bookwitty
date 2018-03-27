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
  
  private init() {
    type = EnvironmentType(rawValue: AppKeys.shared.environmentString) ?? .mockServer
    switch type {
    default:
      baseURL = URL(string: AppKeys.shared.bookwittyServerBaseURLAbsoluteString)!
      googleAnalyticsIdentifier = AppKeys.shared.googleAnalyticsIdentifier
      //Note: this also exists in reverse in the info.plist as a url-type
      googleClientIdentifier = AppKeys.shared.googleClientIdentifier
    }
  }

  var shipementInfoURL: URL? {
    return URL(string: "/shipping?layout=mobile", relativeTo: self.baseURL)
  }
}
