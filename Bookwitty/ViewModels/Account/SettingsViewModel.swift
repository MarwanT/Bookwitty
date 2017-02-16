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

  init () {
    sectionTitles = ["", ""]
  }

  //General
  private func valuesForGeneral(atRow row: Int) -> (title: String, value: Any) {
    switch row {
    case 0: //email
      return (emailNotificationsText, false)
    case 1: //change password
      return (changePasswordText, "")
    case 2: //country/region
      return (countryRegionText, "")
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

  //Sign Out
  private func valuesForSignOut(atRow row: Int) -> (title: String, value: String) {
    return (signOutText, "")
  }

  private func accessoryForSignOut(atRow row: Int) -> Accessory {
      return .None
  }
}
