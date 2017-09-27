//
//  AppNotifications.swift
//  Bookwitty
//
//  Created by Marwan  on 2/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

struct AppNotification {
  static let failToRefreshToken: Notification.Name = Notification.Name(rawValue: "AppNotification.Name.failToRefreshToken")
  static let signOut: Notification.Name = Notification.Name(rawValue: "SignOutNotification")
  static let didSignIn: Notification.Name = Notification.Name(rawValue: "AppNotification.didSignIn")
  static let shouldDisplayRegistration: Notification.Name = Notification.Name(rawValue: "AppNotification.shouldDisplayRegistration")
  static let shouldDisplaySignIn: Notification.Name = Notification.Name(rawValue: "AppNotification.shouldDisplaySignIn")
  static let registrationSuccess: Notification.Name = Notification.Name(rawValue: "AppNotification.registrationSuccess")
  static let shouldRefreshData: Notification.Name = Notification.Name(rawValue: "AppNotification.shouldRefreshData")
  static let didFinishBoarding: Notification.Name = Notification.Name(rawValue: "AppNotification.didFinishBoarding")
  static let didCheckAppStatus: Notification.Name = Notification.Name("AppNotification.didCheckAppStatus")
  static let accountNeedsConfirmation: Notification.Name = Notification.Name("AppNotification.accountNeedsConfirmation")
  static let callToAction: Notification.Name = Notification.Name("AppNotification.callToAction")
  static let authenticationStatusChanged: Notification.Name = Notification.Name("AppNotification.authenticationStatusChanged")
  static let tooManyRequests: Notification.Name = Notification.Name("AppNotification.tooManyRequests")
  static let serverIsBusy: Notification.Name = Notification.Name("AppNotification.serverIsBusy")

  struct Key {
    private init() {}
    static let status: String = "status"
  }
}
