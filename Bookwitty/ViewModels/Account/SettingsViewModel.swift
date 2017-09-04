//
//  SettingsViewModel.swift
//  Bookwitty
//
//  Created by charles on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class SettingsViewModel {
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
      return (Strings.email_notifications(), sendEmailNotification)
    case 1: //newsletter
      let sendNewsletter = GeneralSettings.sharedInstance.shouldSendNewsletter
      return (Strings.newsletter(), sendNewsletter)
    case 2: //change password
      return (Strings.change_password(), "")
    case 3: //change language
      let languageDisplayName: String = Locale.application.localizedString(forLanguageCode: GeneralSettings.sharedInstance.preferredLanguage) ?? ""
      return (Strings.language(), languageDisplayName.capitalized)
    case 4: //country/region
      let countryName = Locale.application.localizedString(forRegionCode: countryCode) ?? ""
      return (Strings.country_region(), countryName)
    default:
      return ("", "")
    }
  }

  private func accessoryForGeneral(atRow row: Int) -> Accessory {
    switch row {
    case 0: //email
      return .Switch
    case 1: //newsletter
      return .Switch
    case 2: //change password
      return .Disclosure
    case 3: //change language
      return .Disclosure
    case 4: //country/region
      return .Disclosure
    default:
      return .None
    }
  }

  private func handleGeneralSwitchValueChanged(atRow row: Int, newValue: Bool, completion: @escaping ((_ value: Bool)->())) {
    switch row {
    case 0: //email
      break
    case 1: //newsletter
      break
    default:
      break
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
    return (Strings.sign_out(), "")
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
      //email notifications, newsletter, change password, change language, country/region
      numberOfRows = 5
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

  func handleSwitchValueChanged(forRowAt indexPath: IndexPath, newValue: Bool, completion: @escaping ((_ value: Bool)->())) {
    switch indexPath.section {
    case Sections.General.rawValue:
      handleGeneralSwitchValueChanged(atRow: indexPath.row, newValue: newValue, completion: completion)
    default:
      break
    }
  }
}
