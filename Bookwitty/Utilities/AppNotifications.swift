//
//  AppNotifications.swift
//  Bookwitty
//
//  Created by Marwan  on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct AppNotification {
  struct Name {
    public static let failToRefreshToken: Notification.Name = Notification.Name(rawValue: "AppNotification.Name.failToRefreshToken")
    public static let didSignIn: Notification.Name = Notification.Name(rawValue: "AppNotification.Name.didSignIn")
    public static let rootShouldDisplayRegistration: Notification.Name = Notification.Name(rawValue: "AppNotification.Name.rootShouldDisplayRegistration")
    public static let introductionShouldDisplayRegistration: Notification.Name = Notification.Name(rawValue: "AppNotification.Name.introductionShouldDisplayRegistration")
  }
}
