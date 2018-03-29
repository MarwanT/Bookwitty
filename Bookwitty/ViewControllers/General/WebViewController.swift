//
//  WebViewController.swift
//  Bookwitty
//
//  Created by Elie Soueidy on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import SafariServices

class WebViewController {
  public static func present(url: String, inViewController: UIViewController? = nil) {
    let presenterViewController: UIViewController = inViewController != nil ? inViewController! : rootViewController
    let safariVC = SFSafariViewController(url: URL(string: url)!)
    safariVC.modalPresentationStyle = .overCurrentContext
    safariVC.modalTransitionStyle = .coverVertical
    if #available(iOS 10.0, *) {
      safariVC.preferredControlTintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    }
    presenterViewController.present(safariVC, animated: true, completion: nil)
  }

  public static func present(url: URL, inViewController: UIViewController? = nil) {
    guard let safeURL = url.withHTTPS else {
      return
    }
    let presenterViewController: UIViewController = inViewController != nil ? inViewController! : rootViewController
    let safariVC = SFSafariViewController(url: safeURL)
    safariVC.modalPresentationStyle = .overCurrentContext
    safariVC.modalTransitionStyle = .coverVertical
    if #available(iOS 10.0, *) {
      safariVC.preferredControlTintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    }
    presenterViewController.present(safariVC, animated: true, completion: nil)
  }
  
  private static var rootViewController: UIViewController {
    guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
      fatalError("No root view controller detected")
    }
    return rootViewController
  }
}
