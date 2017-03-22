//
//  GeneralSettings.swift
//  Bookwitty
//
//  Created by Marwan  on 1/19/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public class GeneralSettings {
  public struct Notifications {
    public static let sendUsageDataValueChanged: Notification.Name = Notification.Name(rawValue: "GeneralSettingsSendUsageDataValueChangedNotification")
  }
  public struct Keys {
    public static let SendUsageData = "SendUsageData"
    public static let SendEmailNotifications = "SendEmailNotifications"
    public static let ShouldShowIntroduction = "ShouldShowIntroduction"
    public static let PreferredLanguage = "PreferredLanguage"
  }

  private let defaults = UserDefaults.standard
  
  public static let sharedInstance: GeneralSettings = GeneralSettings()
  private init() {
    let defaultLanguage = Locale.current.languageCode ?? Localization.Language.English.rawValue

    let defaultValues: [String : Any] = [
      Keys.PreferredLanguage : defaultLanguage,
      Keys.SendUsageData : true,
      Keys.SendEmailNotifications : true,
      Keys.ShouldShowIntroduction : true,
    ]

    defaults.register(defaults: defaultValues)
    shouldSendUsageData = defaults.bool(forKey: Keys.SendUsageData)
    shouldSendEmailNotifications = defaults.bool(forKey: Keys.SendEmailNotifications)
    shouldShowIntroduction = defaults.bool(forKey: Keys.ShouldShowIntroduction)
    preferredLanguage = defaults.string(forKey: Keys.PreferredLanguage) ?? Localization.Language.English.rawValue
  }
  
  public var shouldSendUsageData: Bool {
    didSet {
      defaults.set(self.shouldSendUsageData, forKey: Keys.SendUsageData)
      NotificationCenter.default.post(
        name: GeneralSettings.Notifications.sendUsageDataValueChanged,
        object: self.shouldSendUsageData)
    }
  }

  public var shouldSendEmailNotifications: Bool {
    didSet {
      defaults.set(self.shouldSendEmailNotifications, forKey: Keys.SendEmailNotifications)
    }
  }
 
  public var shouldShowIntroduction: Bool {
    didSet {
      defaults.set(self.shouldShowIntroduction, forKey: Keys.ShouldShowIntroduction)
    }
  }

  public var preferredLanguage: String {
    didSet {
      defaults.set(self.preferredLanguage, forKey: Keys.PreferredLanguage)
    }
  }
}
