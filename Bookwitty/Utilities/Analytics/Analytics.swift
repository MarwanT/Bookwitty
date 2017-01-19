//
//  Analytics.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public final class Analytics {

  fileprivate let dispatchInterval: TimeInterval = 20
  
  struct Event {
    var category: String
    var action: String
    var name: String
    var value: Double
  }
  
  var enabled: Bool {
    return GeneralSettings.sharedInstance.shouldSendUsageData
  }
  
  public static let sharedInstance: Analytics = Analytics()
  private init() {
    self.initializeGoogleAnalytics()
  }
  func send(event: Event) {
  }
  
  func send(screenName: String) {
  }
}

// MARK: - Google Analytics

extension Analytics {
  private var trackingIdentifier: String {
    // TODO: Retrieve the value from cocoapods keys
    return "TRACKING_IDENTIFIER"
  }
  
  fileprivate func initializeGoogleAnalytics() {
    GAI.sharedInstance().tracker(withTrackingId: self.trackingIdentifier)
    GAI.sharedInstance().trackUncaughtExceptions = true
    GAI.sharedInstance().dispatchInterval = self.dispatchInterval
    GAI.sharedInstance().optOut = !self.enabled
    
    switch Environment.current {
    case .localDevice, .mock, .preproduction:
      GAI.sharedInstance().logger.logLevel = GAILogLevel.verbose
    default:
      GAI.sharedInstance().logger.logLevel = GAILogLevel.none
    }
  }
}
