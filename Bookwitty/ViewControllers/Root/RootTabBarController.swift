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
  
  var shouldDisplayRegisterVC: Bool = false
  
  fileprivate var overlayView: UIView!
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeTabBarViewControllers()
    initializeOverlay()
    applyTheme()
    addObservers()
    
    displayOverlay(animated: false)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Display Introduction VC if user is not signed in
    if !viewModel.isUserSignedIn {
      displayOverlay()
      if shouldDisplayRegisterVC {
        shouldDisplayRegisterVC = false
        presentRegisterViewController()
      } else {
        presentIntroductionOrSignInViewController()
      }
      
    } else {
      dismissOverlay()
      GeneralSettings.sharedInstance.didSignInAtLeastOnce = true
    }
  }
  
  private func initializeTabBarViewControllers() {
    let viewController1 = NewsFeedViewController()
    let bookStoreViewController = Storyboard.Books.instantiate(BookStoreViewController.self)
    
    viewController1.tabBarItem = UITabBarItem(
      title: "NEWS",
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    bookStoreViewController.tabBarItem = UITabBarItem(
      title: viewModel.bookStoreTabTitle,
      image: #imageLiteral(resourceName: "books"),
      tag:2)
    
    // Set The View controller
    self.viewControllers = [
      UINavigationController(rootViewController: viewController1),
      UINavigationController(rootViewController: bookStoreViewController)]
    
    // Set Default select tab index
    self.selectedIndex = 0
  }
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(signOut(notificaiton:)), name: AppNotification.signOut, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.signIn(notification:)), name: AppNotification.didSignIn, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.register(notification:)), name: AppNotification.rootShouldDisplayRegistration, object: nil)
    
  }
  
  fileprivate func presentIntroductionOrSignInViewController() {
    displayOverlay()
    
    if viewModel.didSignInAtLeastOnce {
      let signInVC = Storyboard.Access.instantiate(SignInViewController.self)
      signInVC.viewModel.registerNotificationName = AppNotification.rootShouldDisplayRegistration
      let navigationController = UINavigationController(rootViewController: signInVC)
      present(navigationController, animated: true, completion: nil)
    } else {
      let introductionVC = Storyboard.Introduction.instantiate(IntroductionViewController.self)
      let navigationController = UINavigationController(rootViewController: introductionVC)
      present(navigationController, animated: true, completion: nil)
    }
  }
  
  fileprivate func presentRegisterViewController() {
    let registerViewController = Storyboard.Access.instantiate(RegisterViewController.self)
    let navigationViewController = UINavigationController(rootViewController: registerViewController)
    present(navigationViewController, animated: true, completion: nil)
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
    presentIntroductionOrSignInViewController()
    //TODO: Delete user information if any
    //TODO: Pop all controllers
  }
  
  func signIn(notification: Notification) {
    self.dismiss(animated: true) {
      self.dismissOverlay()
    }
  }
  
  func register(notification: Notification) {
    // Upon dismissing the sign in vc, this vc will re-call the `viewDidAppear`
    // And push the registration vc. logic is handeled there.
    shouldDisplayRegisterVC = true
    self.dismiss(animated: true)
  }
}

// MARK: - Overlay Methods
extension RootTabBarController {
  var animationDuration: TimeInterval {
    return 0.44
  }
  
  func initializeOverlay() {
    let customizeOverlay = {
      self.overlayView.alpha = 0
      self.view.addSubview(self.overlayView)
      self.overlayView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: self.view)
    }
    
    guard let launchView = Bundle.main.loadNibNamed("LaunchScreen", owner: nil, options: nil)?.first as? UIView else {
      overlayView = UIView(frame: CGRect.zero)
      overlayView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
      let logoImageView = UIImageView(image: #imageLiteral(resourceName: "bookwitty"))
      logoImageView.constrainWidth("100", height: "100")
      overlayView.addSubview(logoImageView)
      logoImageView.alignCenter(withView: overlayView)
      customizeOverlay()
      return
    }
    overlayView = launchView
    customizeOverlay()
  }
  
  func displayOverlay(animated: Bool = true) {
    changeOverlayAlphaValue(animated: animated, alpha: 1)
  }
  
  func dismissOverlay(animated: Bool = true) {
    changeOverlayAlphaValue(animated: animated, alpha: 0)
  }
  
  func changeOverlayAlphaValue(animated: Bool, alpha: CGFloat, completion: (() -> Void)? = nil) {
    if animated {
      UIView.animate(
        withDuration: animationDuration,
        animations: {
          self.overlayView.alpha = alpha
      }, completion: { (finished) in
        completion?()
      })
    } else {
      overlayView.alpha = alpha
      completion?()
    }
  }
}
