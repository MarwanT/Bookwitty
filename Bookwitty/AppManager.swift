//
//  AppManager.swift
//  Bookwitty
//
//  Created by Marwan  on 3/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Version
import ReachabilitySwift

class AppManager {
  private(set) var appStatus: AppDelegate.Status = AppDelegate.Status.unspecified
  var isCheckingStatus: Bool = false
  
  static let shared = AppManager()

  var version: Version? = Bundle.main.shortVersion

  var versionDescription: String {
    return version?.description ?? ""
  }
  
  var reachability = Reachability()

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
        self.flushNetworkOperations()
        NotificationCenter.default.post(
          name: AppNotification.didCheckAppStatus,
          object: self.appStatus)
      }
      
      guard success, let meta = appMeta,
        let version = self.version,
        let minimumAppVersionString = meta.minimumAppVersion,
        let minimumSupportedVersion = Version(minimumAppVersionString)
      else {
        return
      }
      
      // Store app meta somewhere if needed
      if version >= minimumSupportedVersion {
        self.appStatus = .valid
      } else {
        self.appStatus = .needsUpdate(URL(string: meta.storeURLString ?? ""))
      }
    }
  }
  
  private func flushNetworkOperations() {
    switch appStatus {
    case .valid:
      executePendingOperations(success: true)
    case .unspecified: fallthrough
    case .needsUpdate: fallthrough
    default: executePendingOperations(success: false)
    }
  }
}
