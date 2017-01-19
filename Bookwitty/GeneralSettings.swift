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
}
