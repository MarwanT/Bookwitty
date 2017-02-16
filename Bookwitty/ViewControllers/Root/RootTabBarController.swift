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
    initializeTabBarViewControllers()
    initializeOverlay()
    applyTheme()
    addObservers()
    
    displayOverlay(animated: false)
  }

  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(signOut(notificaiton:)), name: AppNotification.signOut, object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Display Introduction VC if user is not signed in
    if !viewModel.isUserSignedIn {
      presentIntroductionOrSignInViewController()
    } else {
      dismissOverlay()
    }
  }
  
  private func initializeTabBarViewControllers() {
    let viewController1 = NewsFeedViewController()
    let viewController2 = UIViewController()
    
    viewController1.tabBarItem = UITabBarItem(
      title: "NEWS",
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    viewController2.tabBarItem = UITabBarItem(
      title: "POST",
      image: #imageLiteral(resourceName: "createPost"),
      tag:2)
    
    // Set The View controller
    self.viewControllers = [
      UINavigationController(rootViewController: viewController1),
      UINavigationController(rootViewController: viewController2)]
    
    // Set Default select tab index
    self.selectedIndex = 0
  }
  
  private func presentIntroductionOrSignInViewController() {
    if viewModel.didSignInAtLeastOnce {
      let signInVC = Storyboard.Access.instantiate(SignInViewController.self)
      present(signInVC, animated: true, completion: nil)
    } else {
      let introductionVC = Storyboard.Introduction.instantiate(IntroductionViewController.self)
      present(introductionVC, animated: true, completion: nil)
    }
  }
}

// MARK: - Themeable
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
  
  func dismissOverlay(animated: Bool = true) {
    changeOverlayAlphaValue(animated: animated, alpha: 0) {
      self.overlayView.removeFromSuperview()
    }
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
