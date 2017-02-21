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
  
  private init() {
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
