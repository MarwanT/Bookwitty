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
  }

  private let defaults = UserDefaults.standard
  private let defaultValues: [String:Any] = [
    Keys.SendUsageData : true
  ]
  
  public static let sharedInstance: GeneralSettings = GeneralSettings()
  private init() {
    defaults.register(defaults: defaultValues)
    shouldSendUsageData = defaults.bool(forKey: Keys.SendUsageData)
  }
  
  public var shouldSendUsageData: Bool {
    didSet {
      defaults.set(self.shouldSendUsageData, forKey: Keys.SendUsageData)
    }
  }
}
