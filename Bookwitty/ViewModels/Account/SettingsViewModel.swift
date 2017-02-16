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

  var countryName: String = "" //TODO: load the default value

  init () {
    sectionTitles = ["", ""]
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

  private func handleGeneralSwitchValueChanged(atRow row: Int, newValue: Bool) {
    switch row {
    case 0: //email
      GeneralSettings.sharedInstance.shouldSendEmailNotifications = newValue
    default:
      break
    }
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

  func handleSwitchValueChanged(forRowAt indexPath: IndexPath, newValue: Bool) {
    switch indexPath.section {
    case Sections.General.rawValue:
      handleGeneralSwitchValueChanged(atRow: indexPath.row, newValue: newValue)
    default:
      break
    }
  }
}
