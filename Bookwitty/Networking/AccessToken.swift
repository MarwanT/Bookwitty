//
//  AccessToken.swift
//  Bookwitty
//
//  Created by Marwan  on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

private extension Date {
  var isInPast: Bool {
    let now = Date()
    return self.compare(now) == ComparisonResult.orderedAscending
  }
}

// TODO: Save token in keychain

/**
 TODO: REVISE THIS WHOLE CLASS AND IMPLEMENT A BETTER APPROACH
 Based on previous experiences we might be facing multi-threads access problems
 */

public struct AccessToken {
  enum Keys: String {
    case accessTokenKey = "AccessTokenKey"
    case accessTokenExpiry = "AccessTokenExpiry"
    case refreshTokenKey = "RefreshTokenKey"
    case accessTokenIsUpdating = "IsUpdating"
  }
  
  // MARK: - Initializers
  
  public let defaults: UserDefaults
  
  public init() {
    self.defaults = UserDefaults.standard
  }
  
  public mutating func readFromDictionary(dictionary: NSDictionary) {
    let json = JSON(dictionary)
    token = json["access_token"].stringValue
    refresh = json["refresh_token"].stringValue
    let expiresIn = json["expires_in"].doubleValue as TimeInterval
    expiry = Date(timeIntervalSinceNow: expiresIn)
    print("Token: \(token)")
  }
  
  // MARK: - Properties
  
  public var token: String? {
    get {
      let key = defaults.string(forKey: Keys.accessTokenKey.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: Keys.accessTokenKey.rawValue)
    }
  }
  
  public var expiry: Date? {
    get {
      return defaults.object(forKey: Keys.accessTokenExpiry.rawValue) as? Date
    }
    set(newExpiry) {
      defaults.set(newExpiry, forKey: Keys.accessTokenExpiry.rawValue)
    }
  }
  
  public var refresh: String? {
    get {
      let key = defaults.string(forKey: Keys.refreshTokenKey.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: Keys.refreshTokenKey.rawValue)
    }
  }
  
  public var isUpdating: Bool? {
    get {
      let key = defaults.bool(forKey: Keys.accessTokenIsUpdating.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: Keys.accessTokenIsUpdating.rawValue)
    }
  }
  
  public var expired: Bool {
    if let expiry = expiry {
      return expiry.isInPast
    }
    return true
  }
  
  public var isValid: Bool {
    if let token = token, let refresh = refresh {
      return (token.characters.count > 0) && (refresh.characters.count > 0) && !expired
    }
    
    return false
  }
  
  public var hasToken: Bool {
    if let token = token, let refresh = refresh {
      return (token.characters.count > 0) && (refresh.characters.count > 0)
    }
    
    return false
  }
  
  public var updating: Bool {
    if let updating = isUpdating {
      return updating
    }
    return false
  }
  
  public func deleteToken() {
    defaults.removeObject(forKey: Keys.accessTokenKey.rawValue)
    defaults.removeObject(forKey: Keys.accessTokenExpiry.rawValue)
    defaults.removeObject(forKey: Keys.refreshTokenKey.rawValue)
    defaults.removeObject(forKey: Keys.accessTokenIsUpdating.rawValue)
  }
  
  public static func resetAccessTokenFlags() {
    UserDefaults.standard.set(false, forKey: Keys.accessTokenIsUpdating.rawValue)
  }
}
