//
//  AppManager.swift
//  Bookwitty
//
//  Created by Marwan  on 3/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Version

class AppManager {
  private(set) var appStatus: AppDelegate.Status = AppDelegate.Status.unspecified
  var isCheckingStatus: Bool = false
  
  static let shared = AppManager()
  
  private init() {}
  
  /// Listen to AppNotificaiton.didCheckAppStatus for updates
  func checkAppStatus() {
    guard !isCheckingStatus else {
      return
    }
    
    isCheckingStatus = true
    _ = GeneralAPI.status { (success, appMeta, error) in
      defer {
        self.isCheckingStatus = false
        NotificationCenter.default.post(
          name: AppNotification.didCheckAppStatus,
          object: self.appStatus)
      }
      
      guard success, let meta = appMeta,
        let minimumAppVersionString = meta.minimumAppVersion,
        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
        let appVersion = Version(appVersionString),
        let minimumSupportedVersion = Version(minimumAppVersionString)
      else {
        return
      }
      
      // Store app meta somewhere if needed
      
      if appVersion >= minimumSupportedVersion {
        self.appStatus = .valid
      } else {
        self.appStatus = .needsUpdate(URL(string: meta.storeURLString ?? ""))
      }
    }
    
  }
}
