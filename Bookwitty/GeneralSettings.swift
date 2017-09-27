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
    public static let SendNewsletter = "SendNewsletter"
    public static let SendCommentsEmail = "SendCommentsEmail"
    public static let SendFollowersEmail = "SendFollowersEmail"
    public static let ShouldShowIntroduction = "ShouldShowIntroduction"
    public static let PreferredLanguage = "PreferredLanguage"
    public static let ShouldDisplayNewsFeedIntroductoryBanner = "ShouldDisplayNewsFeedIntroductoryBanner"
    public static let ShouldDisplayDiscoverIntroductoryBanner = "ShouldDisplayDiscoverIntroductoryBanner"
    public static let ShouldDisplayBookStoreIntroductoryBanner = "ShouldDisplayBookStoreIntroductoryBanner"
  }

  private let defaults = UserDefaults.standard
  
  public static let sharedInstance: GeneralSettings = GeneralSettings()
  private init() {
    let defaultLanguage = Locale.current.languageCode ?? Localization.Language.English.rawValue

    let defaultValues: [String : Any] = [
      Keys.PreferredLanguage : defaultLanguage,
      Keys.SendUsageData : true,
      Keys.SendEmailNotifications : true,
      Keys.SendCommentsEmail : true,
      Keys.SendFollowersEmail : true,
      Keys.SendNewsletter : true,
      Keys.ShouldShowIntroduction : true,
      Keys.ShouldDisplayNewsFeedIntroductoryBanner : true,
      Keys.ShouldDisplayDiscoverIntroductoryBanner : true,
      Keys.ShouldDisplayBookStoreIntroductoryBanner : true,
    ]

    defaults.register(defaults: defaultValues)
    shouldSendUsageData = defaults.bool(forKey: Keys.SendUsageData)
    shouldSendEmailNotifications = defaults.bool(forKey: Keys.SendEmailNotifications)
    shouldSendCommentsEmail = defaults.bool(forKey: Keys.SendCommentsEmail)
    shouldSendFollowersEmail = defaults.bool(forKey: Keys.SendFollowersEmail)
    shouldSendNewsletter = defaults.bool(forKey: Keys.SendNewsletter)
    shouldShowIntroduction = defaults.bool(forKey: Keys.ShouldShowIntroduction)
    preferredLanguage = defaults.string(forKey: Keys.PreferredLanguage) ?? Localization.Language.English.rawValue
    shouldDisplayNewsFeedIntroductoryBanner = defaults.bool(forKey: Keys.ShouldDisplayNewsFeedIntroductoryBanner)
    shouldDisplayDiscoverIntroductoryBanner = defaults.bool(forKey: Keys.ShouldDisplayDiscoverIntroductoryBanner)
    shouldDisplayBookStoreIntroductoryBanner = defaults.bool(forKey: Keys.ShouldDisplayBookStoreIntroductoryBanner)
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

  public var shouldSendCommentsEmail: Bool {
    didSet {
      defaults.set(self.shouldSendCommentsEmail, forKey: Keys.SendCommentsEmail)
    }
  }

  public var shouldSendFollowersEmail: Bool {
    didSet {
      defaults.set(self.shouldSendFollowersEmail, forKey: Keys.SendFollowersEmail)
    }
  }

  public var shouldSendNewsletter: Bool {
    didSet {
      defaults.set(self.shouldSendNewsletter, forKey: Keys.SendNewsletter)
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
  
  public var shouldDisplayNewsFeedIntroductoryBanner: Bool {
    didSet {
      defaults.set(
        self.shouldDisplayNewsFeedIntroductoryBanner,
        forKey: Keys.ShouldDisplayNewsFeedIntroductoryBanner)
    }
  }
  
  public var shouldDisplayDiscoverIntroductoryBanner: Bool {
    didSet {
      defaults.set(
        self.shouldDisplayDiscoverIntroductoryBanner,
        forKey: Keys.ShouldDisplayDiscoverIntroductoryBanner)
    }
  }
  
  public var shouldDisplayBookStoreIntroductoryBanner: Bool {
    didSet {
      defaults.set(
        self.shouldDisplayBookStoreIntroductoryBanner,
        forKey: Keys.ShouldDisplayBookStoreIntroductoryBanner)
    }
  }
}
