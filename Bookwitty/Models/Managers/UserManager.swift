//
//  UserManager.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class UserManager {
  enum Key: String {
    case signedInUser
  }
  
  static let shared = UserManager()
  
  /**
   Currently the user object is signed in on sign in. If the user object 
   failed to be retrieved then the sign in would be considered as a failure
   
   Setting this property updates the saved object in user defaults
   */
  var signedInUser: User! = nil {
    didSet {
      guard let user = signedInUser else {
        return
      }
      saveSignedInUser(user: user)
    }
  }
  
  var isSignedIn: Bool {
    return AccessToken.shared.isValid
  }
  
  private init() {
    signedInUser = getSignedInUser()
  }
  
  private func saveSignedInUser(user: User) {
    let userDictionary = user.serializeData(options: [.IncludeID, .OmitNullValues])
    UserDefaults.standard.set(userDictionary, forKey: Key.signedInUser.rawValue)
  }
  
  func deleteSignedInUser() {
    signedInUser = nil
    UserDefaults.standard.removeObject(forKey: Key.signedInUser.rawValue)
  }
  
  private func getSignedInUser() -> User? {
    guard let userDictionary = UserDefaults.standard.value(forKey: Key.signedInUser.rawValue) as? [String : Any] else {
      return nil
    }
    
    guard let data = try? JSONSerialization.data(withJSONObject: userDictionary, options: JSONSerialization.WritingOptions.prettyPrinted), let user = User.parseData(data: data)
      else {
        return nil
    }
    
    return user
  }
}
