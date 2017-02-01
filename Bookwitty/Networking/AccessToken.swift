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
public struct AccessToken {
  enum DefaultsKeys: String {
    case AccessTokenKey = "AccessTokenKey"
    case AccessTokenExpiry = "AccessTokenExpiry"
    case RefreshTokenKey = "RefreshTokenKey"
    case AccessTokenIsUpdating = "IsUpdating"
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
  }
  
  // MARK: - Properties
  
  public var token: String? {
    get {
      let key = defaults.string(forKey: DefaultsKeys.AccessTokenKey.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: DefaultsKeys.AccessTokenKey.rawValue)
    }
  }
  
  public var expiry: Date? {
    get {
      return defaults.object(forKey: DefaultsKeys.AccessTokenExpiry.rawValue) as? Date
    }
    set(newExpiry) {
      defaults.set(newExpiry, forKey: DefaultsKeys.AccessTokenExpiry.rawValue)
    }
  }
  
  public var refresh: String? {
    get {
      let key = defaults.string(forKey: DefaultsKeys.RefreshTokenKey.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: DefaultsKeys.RefreshTokenKey.rawValue)
    }
  }
  
  public var isUpdating: Bool? {
    get {
      let key = defaults.bool(forKey: DefaultsKeys.AccessTokenIsUpdating.rawValue)
      return key
    }
    set(newToken) {
      defaults.set(newToken, forKey: DefaultsKeys.AccessTokenIsUpdating.rawValue)
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
    defaults.removeObject(forKey: DefaultsKeys.AccessTokenKey.rawValue)
    defaults.removeObject(forKey: DefaultsKeys.AccessTokenExpiry.rawValue)
    defaults.removeObject(forKey: DefaultsKeys.RefreshTokenKey.rawValue)
    defaults.removeObject(forKey: DefaultsKeys.AccessTokenIsUpdating.rawValue)
  }
}
