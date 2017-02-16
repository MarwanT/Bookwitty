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
}
