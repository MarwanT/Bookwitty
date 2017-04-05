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

/**
 In case the user is signed in, then this means we have:
 - Token
 - Refresh Token
 - Expiry Date
 
 In case the user is not signed in, then we should be retrieving an access token
 and use it for signing requests, in that case the token would not have
 a refresh token. what we would be left with is
 - Token
 - Expiry Date
 
 
 */
class AccessToken {
  enum Keys: String {
    case token = "AccessToken.Keys.token"
    case expiryDate = "AccessToken.Keys.expiryDate"
    case refreshToken = "AccessToken.Keys.refreshToken"
    case updating = "AccessToken.Keys.updating"
  }
  
  private let defaults: UserDefaults
  
  public static let shared: AccessToken = AccessToken()
  
  private init() {
    defaults = UserDefaults.standard
  }
  
  public func save(dictionary: NSDictionary) {
    let json = JSON(dictionary)
    
    let tokenValue = json["access_token"].string
    let refreshValue = json["refresh_token"].string
    let expiresIn = json["expires_in"].doubleValue as TimeInterval
    let expiry = Date(timeIntervalSinceNow: expiresIn)
    
    defaults.set(tokenValue, forKey: Keys.token.rawValue)
    defaults.set(refreshValue, forKey: Keys.refreshToken.rawValue)
    defaults.set(expiry, forKey: Keys.expiryDate.rawValue)
    defaults.set(false, forKey: Keys.updating.rawValue)
  }
  
  // MARK: - Properties APIs
  
  var token: String? {
    return defaults.string(forKey: Keys.token.rawValue)
  }
  
  var expiryDate: Date? {
    return defaults.object(forKey: Keys.expiryDate.rawValue) as? Date
  }
  
  var refreshToken: String? {
    return defaults.string(forKey: Keys.refreshToken.rawValue)
  }
  
  var updating: Bool? {
    get {
      return defaults.bool(forKey: Keys.updating.rawValue)
    }
    set {
      defaults.set(newValue ?? false, forKey: Keys.updating.rawValue)
    }
  }
  
  
  // MARK: - Helpers
  
  private var isExpired: Bool {
    guard let expiryDate = expiryDate else {
      return true
    }
    return expiryDate.isInPast
  }
  
  var hasToken: Bool {
    guard let token = token else {
      return false
    }
    return token.characters.count > 0
  }
  
  var hasRefreshToken: Bool {
    guard let refreshToken = refreshToken else {
      return false
    }
    return refreshToken.characters.count > 0
  }
  
  /**
   Checks if the user
   - (Have token) & (Not expired)
   
   The access token is not checked here for this only determines if the user
   is signed in or not, for sign in token there must be a refresh token.
   For guest user no refresh token is required
   */
  var isValid: Bool {
    return hasToken && !isExpired
  }
  
  var isUpdating: Bool {
    if let updating = updating {
      return updating
    }
    return false
  }
  
  func deleteToken() {
    defaults.removeObject(forKey: Keys.token.rawValue)
    defaults.removeObject(forKey: Keys.expiryDate.rawValue)
    defaults.removeObject(forKey: Keys.refreshToken.rawValue)
    defaults.removeObject(forKey: Keys.updating.rawValue)
  }
}
