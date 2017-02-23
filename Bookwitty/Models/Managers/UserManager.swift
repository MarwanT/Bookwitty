//
//  UserManager.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class UserManager {
  struct Key {
    static let SignedInUser = "SignInUser"
    static let SignedInUserPenNames = "SignedInUserPenNames"
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
    let userDictionary = user.serializeData(options: [.IncludeID, .OmitNullValues, .IncludeToOne, .IncludeToMany])
    let penNamesArray = user.penNames?.map({ $0.serializeData(options: [.IncludeID, .OmitNullValues, .IncludeToOne, .IncludeToMany]) })

    UserDefaults.standard.set(userDictionary, forKey: Key.SignedInUser)
    UserDefaults.standard.set(penNamesArray, forKey: Key.SignedInUserPenNames)
  }
  
  func deleteSignedInUser() {
    signedInUser = nil
    UserDefaults.standard.removeObject(forKey: Key.SignedInUser)
  }
  
  private func getSignedInUser() -> User? {
    guard let userDictionary = UserDefaults.standard.value(forKey: Key.SignedInUser) as? [String : Any] else {
      return nil
    }
    
    guard let data = try? JSONSerialization.data(withJSONObject: userDictionary, options: JSONSerialization.WritingOptions.prettyPrinted),
      let user = User.parseData(data: data) else {
        return nil
    }

    guard let userPenNamesArray = UserDefaults.standard.value(forKey: Key.SignedInUserPenNames) as? [[String : Any]] else {
      return user
    }

    let penNames = userPenNamesArray.flatMap({ penNameDictionary -> PenName? in
      guard let data = try? JSONSerialization.data(withJSONObject: penNameDictionary, options: JSONSerialization.WritingOptions.prettyPrinted),
        let penName = PenName.parseData(data: data) else {
          return nil
      }

      return penName
    })

    user.penNames = penNames
    return user
  }
}
