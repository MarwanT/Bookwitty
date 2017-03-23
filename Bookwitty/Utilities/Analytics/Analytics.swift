//
//  Analytics.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import FacebookCore

internal final class Analytics {

  fileprivate let dispatchInterval: TimeInterval = 20
  
  var enabled: Bool {
    return GeneralSettings.sharedInstance.shouldSendUsageData
  }
  
  static let shared: Analytics = Analytics()
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
  
  @objc
  fileprivate func sendUsageDataValueChanged(notification: NSNotification) {
    GAI.sharedInstance().optOut = !self.enabled
  }
  
  func send(event: Event) {
    self.sendGoogle(event: event)
    
    // Facebook don't have a built in OptOut option.
    if self.enabled {
      sendFacebook(event: event)
    }
  }
  
  func send(screenName: ScreenName) {
    self.sendGoogle(screenName: screenName)
  }

  func set(field: Field, value: String) {
    self.setGoogle(field: field, value: value)
  }
}

// MARK: - Google Analytics

extension Analytics {
  private var trackingIdentifier: String {
    return Environment.current.googleAnalyticsIdentifier
  }
  
  fileprivate func initializeGoogleAnalytics() {
    GAI.sharedInstance().tracker(withTrackingId: self.trackingIdentifier)
    GAI.sharedInstance().trackUncaughtExceptions = true
    GAI.sharedInstance().dispatchInterval = self.dispatchInterval
    GAI.sharedInstance().optOut = !self.enabled
    
    switch Environment.current.type {
    case .mockLocal, .mockServer, .development,.staging:
      GAI.sharedInstance().logger.logLevel = GAILogLevel.verbose
    default:
      GAI.sharedInstance().logger.logLevel = GAILogLevel.none
    }
  }
  
  fileprivate func sendGoogle(screenName: ScreenName) {
    
    guard GAI.sharedInstance().defaultTracker != nil else {
      return
    }
    
    GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: screenName.name)
    let gADictionary: NSMutableDictionary = GAIDictionaryBuilder.createScreenView().build()
    
    GAI.sharedInstance().defaultTracker.send(gADictionary as [NSObject : AnyObject])
  }
  
  fileprivate func sendGoogle(event: Event) {
    guard GAI.sharedInstance().defaultTracker != nil else {
      return
    }
    
    let gACategory: String = event.category.name
    let gAAction: String = event.action.name
    let gALabel: String = event.name
    let gADictionaryBuilder: GAIDictionaryBuilder = GAIDictionaryBuilder.createEvent(withCategory: gACategory, action: gAAction, label: gALabel, value: NSNumber(value: event.value))
    let gADictionary: NSMutableDictionary = gADictionaryBuilder.build()
    
    GAI.sharedInstance().defaultTracker.send(gADictionary as [NSObject : AnyObject])
  }

  fileprivate func setGoogle(field: Field, value: String) {
    var key: String = ""
    switch field {
    case .ApplicationVersion:
      key = kGAIAppVersion
    case .UserIdentifier:
      key = kGAIUserId
    }

    GAI.sharedInstance().defaultTracker.set(key, value: value)
  }
}

// MARK: - Facebook Analytics

extension Analytics {
  fileprivate func sendFacebook(event: Event) {
    var eventName: String = event.category.name
    
    if !event.action.name.isEmpty {
      eventName += "-" + event.action.name
    }
    
    if !event.name.isEmpty {
      eventName += "-" + event.name
    }
    
    AppEventsLogger.log(eventName)
  }
}
