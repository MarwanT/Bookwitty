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
}
