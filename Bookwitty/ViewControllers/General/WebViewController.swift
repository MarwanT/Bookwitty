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
  public static func present(url: String, inViewController: UIViewController) {
    let safariVC = SFSafariViewController(url: URL(string: url)!)
    safariVC.modalPresentationStyle = .overCurrentContext
    safariVC.modalTransitionStyle = .coverVertical
    if #available(iOS 10.0, *) {
      safariVC.preferredControlTintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    }
    inViewController.present(safariVC, animated: true, completion: nil)
  }

  public static func present(url: URL!, inViewController: UIViewController) {
    let safariVC = SFSafariViewController(url: url)
    safariVC.modalPresentationStyle = .overCurrentContext
    safariVC.modalTransitionStyle = .coverVertical
    if #available(iOS 10.0, *) {
      safariVC.preferredControlTintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    }
    inViewController.present(safariVC, animated: true, completion: nil)
  }
}
