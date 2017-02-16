//
//  RootTabbarViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import FLKAutoLayout

class RootTabBarController: UITabBarController {
  let viewModel = RootTabBarViewModel()
  
  fileprivate var overlayView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeOverlay()
    applyTheme()
    addObservers()
    
    //Set Default select tab index
    self.selectedIndex = 0

    let placeholderVc1 = NewsFeedViewController()
    let placeholderVc2 = UIViewController()
    
    placeholderVc1.tabBarItem = UITabBarItem(
      title: "NEWS",
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    placeholderVc2.tabBarItem = UITabBarItem(
      title: "POST",
      image: #imageLiteral(resourceName: "createPost"),
      tag:2)

    //Set The View controller
    self.viewControllers = [UINavigationController(rootViewController: placeholderVc1),
                            UINavigationController(rootViewController: placeholderVc2)]
  }

  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(signOut(notificaiton:)), name: AppNotification.signOut, object: nil)
  }

}

extension RootTabBarController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

//MARK: - Notifications
extension RootTabBarController {
  func signOut(notificaiton: Notification) {
    AccessToken.shared.deleteToken()
    //TODO: Delete user information if any
    //TODO: Pop all controllers
    //TODO: Present sign in / register controller 
  }
}

// MARK: - Overlay Methods
extension RootTabBarController {
  var animationDuration: TimeInterval {
    return 0.44
  }
  
  func initializeOverlay() {
    overlayView = Bundle.main.loadNibNamed(
      "LaunchScreen", owner: nil, options: nil)![0] as! UIView
    overlayView.alpha = 0
  }
  
  func displayOverlay(animated: Bool = true) {
    let isAlreadyAddedToViewHierarchy = (overlayView.superview != nil)
    if !isAlreadyAddedToViewHierarchy {
      view.addSubview(overlayView)
      overlayView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: view)
    }
    changeOverlayAlphaValue(animated: animated, alpha: 1, completion: {})
  }
  
  func changeOverlayAlphaValue(animated: Bool, alpha: CGFloat, completion: @escaping () -> Void) {
    if animated {
      UIView.animate(
        withDuration: animationDuration,
        animations: {
          self.overlayView.alpha = alpha
      }, completion: { (finished) in
        completion()
      })
    } else {
      overlayView.alpha = alpha
      completion()
    }
  }
}
