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
}
