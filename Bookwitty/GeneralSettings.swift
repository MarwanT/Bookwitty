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
  }

  private let defaults = UserDefaults.standard
  private let defaultValues: [String:Any] = [
    Keys.SendUsageData : true,
    Keys.SendEmailNotifications : true,
    Keys.ShouldShowIntroduction : true
  ]
  
  public static let sharedInstance: GeneralSettings = GeneralSettings()
  private init() {
    defaults.register(defaults: defaultValues)
    shouldSendUsageData = defaults.bool(forKey: Keys.SendUsageData)
    shouldSendEmailNotifications = defaults.bool(forKey: Keys.SendEmailNotifications)
    shouldShowIntroduction = defaults.bool(forKey: Keys.ShouldShowIntroduction)
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
}
