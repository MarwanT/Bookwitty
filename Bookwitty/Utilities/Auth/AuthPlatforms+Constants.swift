//
//  AuthPlatforms+Constants.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/21.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

enum AuthPlatforms: String {
  case bookwitty = "bookwitty"
  case facebook = "facebook"

  struct AuthErrors {
    private init() {}
    static let domain: String = "AuthPlatforms"
    static let error = NSError(domain: AuthErrors.domain, code: 1, userInfo: nil)
    static let facebookAuthMissingEmailError = NSError(domain: AuthErrors.domain, code: 2, userInfo: nil)
  }
}
