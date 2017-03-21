//
//  Localization.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

typealias Count = Int

func localizedString(key: String, defaultValue: String = "", count: Count = 0, comment: String = "") -> String {
  return NSLocalizedString(key, value: defaultValue, comment: comment)
}


protocol Localizable {
  func applyLocalization()
}

final class Localization {

  enum Language: String {
    case English = "en"
    case French = "fr"

    static func all() -> [Language] {
      return [.English, .French]
    }
  }

  struct Notifications {
    struct Name {
      static let languageValueChanged: Notification.Name = Notification.Name(rawValue: "Localization.Language.ValueChanged")
    }

    struct Key {
      static let UserInfoKeyOld = "Localization.Language.Key.old"
      static let UserInfoKeyNew = "Localization.Language.Key.new"
    }
  }

  //Sets the Application Language
  static func set(language: Language?) {
    let newLanguage = language ?? .English
    let oldLanguage = Language(rawValue: GeneralSettings.sharedInstance.preferredLanguage)
    
    Bundle.setLanguage(newLanguage.rawValue)
    GeneralSettings.sharedInstance.preferredLanguage = newLanguage.rawValue
    postNotificationIfNeeded(new: language, old: oldLanguage)
  }

  //Post Language Changed Notification 
  //Only if the Language Selected is Different than the current one
  static func postNotificationIfNeeded(new: Language?, old: Language?) {
    guard let new = new, let old = old else {
      return
    }

    guard new != old else {
      return
    }

    let info = [
      Notifications.Key.UserInfoKeyOld : old.rawValue,
      Notifications.Key.UserInfoKeyNew : new.rawValue
    ]

    NotificationCenter.default.post(name: Notifications.Name.languageValueChanged, object: nil, userInfo: info)
  }
}
