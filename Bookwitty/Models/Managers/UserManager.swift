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
    static let SignedInUserDefaultPenName = "SignedInUserDefaultPenName"
    static let ShouldEditPenName = "ShouldEditPenName"
    static let ShouldDisplayOnboarding = "ShouldDisplayOnboarding"
  }
  
  static let shared = UserManager()
  
  /**
   A session related variable just to indicate whether the user did
   open Onboarding for this session.
   */
  var didOpenOnboarding: Bool = false

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
      notifyUpdate(user: true)
    }
  }
  
  var isSignedIn: Bool {
    return AccessToken.shared.hasToken && AccessToken.shared.hasRefreshToken && signedInUser != nil
  }

  var isOnboarded: Bool {
    return signedInUser != nil && signedInUser.onboardCompleteAt != nil
  }

  var shouldEditPenName: Bool {
    get {
      return UserDefaults.standard.bool(forKey: Key.ShouldEditPenName) 
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Key.ShouldEditPenName)
    }
  }
  
  var shouldDisplayOnboarding: Bool {
    return isSignedIn && !isOnboarded && !didOpenOnboarding
  }

  var penNames: [PenName]? {
    get {
      return isSignedIn ? signedInUser.penNames : nil
    }
    set {
      guard let penNames = newValue else {
        return
      }
      signedInUser.penNames = penNames
      saveSignedInUserPenNames(penNames: penNames)
      notifyUpdate(user: false, names: true)
    }
  }

  func append(penName: PenName) {
    var penNames = signedInUser.penNames ?? []
    penNames.append(penName)
    signedInUser.penNames = penNames
    saveSignedInUserPenNames(penNames: penNames)
    notifyUpdate(user: false, names: true)
  }

  var defaultPenName: PenName? {
    return getUserDefaultPenName()
  }

  private init() {
    signedInUser = getSignedInUser()
  }
  
  private func saveSignedInUser(user: User) {
    let userDictionary = user.serializeData(options: [.IncludeID, .OmitNullValues, .IncludeToOne, .IncludeToMany])
    let penNamesArray = user.penNames?.map({ $0.serializeData(options: [.IncludeID, .OmitNullValues, .IncludeToOne, .IncludeToMany]) })
    

    UserDefaults.standard.set(userDictionary, forKey: Key.SignedInUser)
    UserDefaults.standard.set(penNamesArray, forKey: Key.SignedInUserPenNames)

    //MARK: [Analytics] Field
    Analytics.shared.set(field: Analytics.Field.UserIdentifier, value: user.id ?? "")

    if let firstPenName = user.penNames?.first {
      //On sign-in save the first name as the default one
      saveDefaultPenName(penName: firstPenName)
    }
  }

  func saveDefaultPenName(penName: PenName) {
    if let id = penName.id {
      UserDefaults.standard.set(id, forKey: Key.SignedInUserDefaultPenName)
    }
  }
  
  func deleteSignedInUser() {
    signedInUser = nil
    UserDefaults.standard.removeObject(forKey: Key.SignedInUser)
  }

  private func getUserDefaultPenName() -> PenName? {
    guard let penNames = penNames, penNames.count > 0 else {
      return nil
    }
    guard let defaultPenNameId = UserDefaults.standard.value(forKey: Key.SignedInUserDefaultPenName) as? String else {
      //If No PenName is set, set the default at index 0
      return penNames.first
    }

    guard let index = penNames.index(where: { $0.id == defaultPenNameId }) else {
      return penNames.first
    }
    return penNames[index]
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

  private func saveSignedInUserPenNames(penNames: [PenName]) {
    let penNamesArray = penNames.map({ $0.serializeData(options: [.IncludeID, .OmitNullValues, .IncludeToOne, .IncludeToMany]) })
    UserDefaults.standard.set(penNamesArray, forKey: Key.SignedInUserPenNames)
  }

  func replaceUpdated(penName: PenName?) {
    guard let penName = penName else {
      return
    }

    if let index = self.signedInUser.penNames?.index(where: { $0.id == penName.id }) {
      signedInUser.penNames?[index] = penName
    }

    if getUserDefaultPenName()?.id == penName.id {
      saveDefaultPenName(penName: penName)
    }

    saveSignedInUserPenNames(penNames: signedInUser.penNames ?? [])
    notifyUpdate(user: false, names: true)
  }

  func isMy(penName: PenName) -> Bool {
    guard isSignedIn else {
      return false
    }
    return signedInUser.isMy(penName: penName)
  }

  func isMyDefault(penName: PenName) -> Bool {
    guard isSignedIn, let defaultPenName = defaultPenName else {
      return false
    }
    return defaultPenName.id == penName.id
  }
}

extension UserManager {
  fileprivate func notifyUpdate(user: Bool = false, names: Bool = false) {
    if user {
      NotificationCenter.default.post(name: Notifications.Name.UpdateUser, object: signedInUser)
    }

    if names {
      NotificationCenter.default.post(name: Notifications.Name.UpdatePenNames, object: penNames ?? [])
    }
  }
}

//MARK: - Notifications
extension UserManager {
  struct Notifications {
    struct Name {
      static let UpdateUser = Notification.Name("UserManager.Notifications.Name.UpdateUser")
      static let UpdatePenNames = Notification.Name("UserManager.Notifications.Name.UpdatePenNames")
    }
  }
}
