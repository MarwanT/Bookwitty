//
//  SettingsViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class SettingsViewModel {
  let viewControllerTitle: String = localizedString(key: "settings", defaultValue: "Settings")
  let emailNotificationsText: String = localizedString(key: "email_notifications", defaultValue: "Email Notifications")
  let changePasswordText: String = localizedString(key: "change_password", defaultValue: "Change Password")
  let countryRegionText: String = localizedString(key: "country_regions", defaultValue: "Country/Region")
  let signOutText: String = localizedString(key: "sign_out", defaultValue: "Sign Out")

  enum Sections: Int {
    case General = 0
    case SignOut = 1
  }

  enum Accessory {
    case Disclosure
    case Switch
    case None
  }

  private let sectionTitles: [String]

  private let user: User = UserManager.shared.signedInUser

  var countryCode: String = ""

  init () {
    sectionTitles = ["", ""]
    countryCode = user.country ?? (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String ?? ""
  }

  //General
  private func valuesForGeneral(atRow row: Int) -> (title: String, value: Any) {
    switch row {
    case 0: //email
      let sendEmailNotification = GeneralSettings.sharedInstance.shouldSendEmailNotifications
      return (emailNotificationsText, sendEmailNotification)
    case 1: //change password
      return (changePasswordText, "")
    case 2: //country/region
      let countryName = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode) ?? ""
      return (countryRegionText, countryName)
    default:
      return ("", "")
    }
  }

  private func accessoryForGeneral(atRow row: Int) -> Accessory {
    switch row {
    case 0: //email
      return .Switch
    case 1: //change password
      return .Disclosure
    case 2: //country/region
      return .Disclosure
    default:
      return .None
    }
  }

  private func handleGeneralSwitchValueChanged(atRow row: Int, newValue: Bool, completion: @escaping (()->())) {
    switch row {
    case 0: //email
      updateUserPreferences(value: "\(newValue)", completion: { (success: Bool) -> () in
        if success {
          GeneralSettings.sharedInstance.shouldSendEmailNotifications = newValue
        }
        completion()
      })
    default:
      break
    }
  }

  private func updateUserPreferences(value: String, completion: @escaping ((Bool)->())) {
    var followersPreferenceSuccess: Bool = false
    var commentsPreferenceSuccess: Bool = false

    let group = DispatchGroup()
    group.enter()
    _ = UserAPI.updateUser(preference: User.Preference.emailNotificationFollowers, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      followersPreferenceSuccess = success
      group.leave()
    }

    group.enter()
    _ = UserAPI.updateUser(preference: User.Preference.emailNotificationComments, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      commentsPreferenceSuccess = success
      group.leave()
    }

    group.notify(queue: DispatchQueue.main) {
      completion(followersPreferenceSuccess && commentsPreferenceSuccess)
    }
  }

  func updateUserCountry(country: String, completion:((Bool)->())?) {
    guard let identifier = user.id else {
      completion?(false)
      return
    }

    _ = UserAPI.updateUser(identifier: identifier, countryISO3166: country, completionBlock: {
      (success: Bool, user: User?, error: BookwittyAPIError?) in
      if success {
        self.countryCode = country
      }
      completion?(success)
    })
  }

  //Sign Out
  private func valuesForSignOut(atRow row: Int) -> (title: String, value: String) {
    return (signOutText, "")
  }

  private func accessoryForSignOut(atRow row: Int) -> Accessory {
      return .None
  }

  /*
   * General table view functions
   */
  func numberOfSections() -> Int {
    return self.sectionTitles.count
  }

  func titleFor(section: Int) -> String {
    guard section >= 0 && section < self.sectionTitles.count else { return "" }

    return self.sectionTitles[section]
  }

  func numberOfRowsIn(section: Int) -> Int {
    guard section >= 0 && section < self.sectionTitles.count else { return 0 }

    var numberOfRows = 0
    switch section {
    case Sections.General.rawValue:
      //email notifications, change password, country/region
      numberOfRows = 3
    case Sections.SignOut.rawValue:
      //sign out
      numberOfRows = 1
    default:
      break
    }
    return numberOfRows
  }

  func values(forRowAt indexPath: IndexPath) -> (title: String, value: Any) {
    var title: String = ""
    var value: Any = ""
    switch indexPath.section {
    case Sections.General.rawValue:
      let values = valuesForGeneral(atRow: indexPath.row)
      title = values.title
      value = values.value
    case Sections.SignOut.rawValue:
      let values = valuesForSignOut(atRow: indexPath.row)
      title = values.title
      value = values.value
    default:
      break
    }
    return (title, value)
  }

  func accessory(forRowAt indexPath: IndexPath) -> Accessory {
    var accessory: Accessory = .None
    switch indexPath.section {
    case Sections.General.rawValue:
      return accessoryForGeneral(atRow: indexPath.row)
    case Sections.SignOut.rawValue:
      accessory = accessoryForSignOut(atRow: indexPath.row)
    default:
      accessory = .None
    }
    return accessory
  }

  func handleSwitchValueChanged(forRowAt indexPath: IndexPath, newValue: Bool, completion: @escaping (()->())) {
    switch indexPath.section {
    case Sections.General.rawValue:
      handleGeneralSwitchValueChanged(atRow: indexPath.row, newValue: newValue, completion: completion)
    default:
      break
    }
  }
}
