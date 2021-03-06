//
//  AppDelegate.swift
//  Bookwitty
//
//  Created by Marwan  on 1/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FacebookCore
import SwiftLoader

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Register User Agent for network requests
    UserDefaults.standard.register(defaults: ["UserAgent" : APIProvider.userAgentValue])
    
    applyTheme()
    
    // Reset flag when application starts
    AccessToken.shared.updating = false

    let preferredLanguage = GeneralSettings.sharedInstance.preferredLanguage
    Localization.set(language: Localization.Language(rawValue: preferredLanguage))
    
    SwiftLoader.configure()
    
    Fabric.with([Crashlytics.self, Answers.self])
    SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

    IFramely.shared.initializeWith(apiKey: AppKeys.shared.iframelyKey)

    //MARK: [Analytics] Field
    Analytics.shared.set(field: .ApplicationVersion, value: AppManager.shared.versionDescription)

    AppManager.shared.checkAppStatus()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    AppEventsLogger.activate(application)
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
    return handled
  }
}

extension AppDelegate: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.initialize()
  }
}

// MARK: - Application Status
extension AppDelegate {
  enum Status {
    case valid
    case needsUpdate(URL?)
    case unspecified
  }
}

// MARK: - General
extension AppDelegate {
  static func openSettings() {
    guard let identifier = Bundle.main.bundleIdentifier, let settingsUrl = URL(string: UIApplicationOpenSettingsURLString+identifier) else {
      return
    }
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.openURL(settingsUrl)
    }
  }
}
