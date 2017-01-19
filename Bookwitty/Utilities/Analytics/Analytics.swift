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
  
  var enabled: Bool {
    return GeneralSettings.sharedInstance.shouldSendUsageData
  }
  
  public static let sharedInstance: Analytics = Analytics()
  private init() {
    self.initializeGoogleAnalytics()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.sendUsageDataValueChanged(notification:)) ,
      name: GeneralSettings.Notifications.sendUsageDataValueChanged,
      object: nil)
  }
  
  deinit{
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func sendUsageDataValueChanged(notification: NSNotification) {
    GAI.sharedInstance().optOut = !self.enabled
  }
  
  func send(event: Event) {
    self.sendGoogleAnalytics(event: event)
  }
  
  func send(screenName: String) {
    self.sendGoogleAnalytics(screenName: screenName)
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
  
  fileprivate func sendGoogleAnalytics(screenName: String) {
    
    guard GAI.sharedInstance().defaultTracker != nil else {
      return
    }
    
    GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: screenName)
    let gADictionary: NSMutableDictionary = GAIDictionaryBuilder.createScreenView().build()
    
    GAI.sharedInstance().defaultTracker.send(gADictionary as [NSObject : AnyObject])
  }
  
  fileprivate func sendGoogleAnalytics(event: Event) {
    guard GAI.sharedInstance().defaultTracker != nil else {
      return
    }
    
    let gACategory: String = event.category
    let gAAction: String = event.action
    let gALabel: String = event.name
    let gADictionaryBuilder: GAIDictionaryBuilder = GAIDictionaryBuilder.createEvent(withCategory: gACategory, action: gAAction, label: gALabel, value: NSNumber(value: event.value))
    let gADictionary: NSMutableDictionary = gADictionaryBuilder.build()
    
    GAI.sharedInstance().defaultTracker.send(gADictionary as [NSObject : AnyObject])
  }
}
