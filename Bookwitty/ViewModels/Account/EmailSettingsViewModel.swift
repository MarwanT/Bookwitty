//
//  EmailSettingsViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/01.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class EmailSettingsViewModel {

  enum Sections: Int {
    case Email = 0
  }

  enum Accessory {
    case Disclosure
    case Switch
    case None
  }

  private let sectionTitles: [String]

  init () {
    sectionTitles = [""]
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
    case Sections.Email.rawValue:
      //comments, followers, newsletter
      numberOfRows = 4
    default:
      break
    }
    return numberOfRows
  }

  func values(forRowAt indexPath: IndexPath) -> (title: String, value: Any) {
    var title: String = ""
    var value: Any = ""
    switch indexPath.section {
    case Sections.Email.rawValue:
      let values = valuesForEmail(atRow: indexPath.row)
      title = values.title
      value = values.value
    default:
      break
    }
    return (title, value)
  }

  //Email
  private func valuesForEmail(atRow row: Int) -> (title: String, value: Any) {
    switch row {
    case 0: //comments
      let sendEmailNotification = GeneralSettings.sharedInstance.shouldSendCommentsEmail
      return (Strings.comments(), sendEmailNotification)
    case 1: //followers
      let sendEmailNotification = GeneralSettings.sharedInstance.shouldSendFollowersEmail
      return (Strings.followers(), sendEmailNotification)
    case 2: //newsletter
      let sendNewsletter = GeneralSettings.sharedInstance.shouldSendNewsletter
      return (Strings.newsletter(), sendNewsletter)
    case 3: //wits
      let sendEmailNotification = GeneralSettings.sharedInstance.shouldSendWitsEmail
      return (Strings.wits(), sendEmailNotification)
    default:
      return ("", "")
    }
  }

  func accessory(forRowAt indexPath: IndexPath) -> Accessory {
    var accessory: Accessory = .None
    switch indexPath.section {
    case Sections.Email.rawValue:
      return accessoryForEmail(atRow: indexPath.row)
    default:
      accessory = .None
    }
    return accessory
  }

  private func accessoryForEmail(atRow row: Int) -> Accessory {
    switch row {
    case 0: //comments
      return .Switch
    case 1: //followers
      return .Switch
    case 2: //newsletter
      return .Switch
    case 3: //wits
      return .Switch
    default:
      return .None
    }
  }

  func handleSwitchValueChanged(forRowAt indexPath: IndexPath, newValue: Bool, completion: @escaping ((_ value: Bool)->())) {
    switch indexPath.section {
    case Sections.Email.rawValue:
      handleEmailSwitchValueChanged(atRow: indexPath.row, newValue: newValue, completion: completion)
    default:
      break
    }
  }

  private func handleEmailSwitchValueChanged(atRow row: Int, newValue: Bool, completion: @escaping ((_ value: Bool)->())) {
    switch row {
    case 0: //comments
      updateUserEmailCommentsPreference(value: "\(!newValue)", completion: { (success: Bool) in
        if success {
          GeneralSettings.sharedInstance.shouldSendCommentsEmail = newValue
        }
        completion(GeneralSettings.sharedInstance.shouldSendCommentsEmail)
      })
    case 1: //followers
      updateUserEmailFollowersPreference(value: "\(!newValue)", completion: { (success: Bool) in
        if success {
          GeneralSettings.sharedInstance.shouldSendFollowersEmail = newValue
        }
        completion(GeneralSettings.sharedInstance.shouldSendFollowersEmail)
      })
    case 2: //newsletter
      updateUserEmailNewsletterPreference(value: "\(!newValue)", completion: { (success: Bool) in
        if success {
          GeneralSettings.sharedInstance.shouldSendNewsletter = newValue
        }
        completion(GeneralSettings.sharedInstance.shouldSendNewsletter)
      })
    case 3: //wits
      updateUserEmailWitsPreference(value: "\(!newValue)", completion: { (success: Bool) in
        if success {
          GeneralSettings.sharedInstance.shouldSendWitsEmail = newValue
        }
        completion(GeneralSettings.sharedInstance.shouldSendWitsEmail)
      })
    default:
      break
    }
  }
}

//MARK: - API Handlers
extension EmailSettingsViewModel {
  fileprivate func updateUserEmailCommentsPreference(value: String, completion: @escaping ((Bool)->())) {
    _ = UserAPI.updateUser(preference: User.Preference.emailNotificationComments, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      completion(success)
    }
  }

  fileprivate func updateUserEmailFollowersPreference(value: String, completion: @escaping ((Bool)->())) {
    _ = UserAPI.updateUser(preference: User.Preference.emailNotificationFollowers, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      completion(success)
    }
  }

  fileprivate func updateUserEmailNewsletterPreference(value: String, completion: @escaping ((Bool)->())) {
    _ = UserAPI.updateUser(preference: User.Preference.emailNewsletter, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      completion(success)
    }
  }

  fileprivate func updateUserEmailWitsPreference(value: String, completion: @escaping ((Bool)->())) {
    _ = UserAPI.updateUser(preference: User.Preference.emailNotificationWits, value: value) {
      (success: Bool, error: BookwittyAPIError?) in
      completion(success)
    }
  }
}
