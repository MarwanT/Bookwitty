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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    removeObserversWhenVisible()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    addObserversWhenNotVisible()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Display Introduction VC if user is not signed in
    if !UserManager.shared.isSignedIn {
      displayOverlay()
      presentIntroductionOrSignInViewController()
    } else {
      if UserManager.shared.shouldEditPenName {
        presentPenNameViewController(user: UserManager.shared.signedInUser)
      } else if UserManager.shared.shouldDisplayOnboarding {
        presentOnboardingViewController()
      } else {
        dismissOverlay()
        GeneralSettings.sharedInstance.shouldShowIntroduction = false
        NotificationCenter.default.post(
          name: AppNotification.shouldRefreshData, object: nil)
      }
    }
  }
  
  private func initializeTabBarViewControllers() {
    let viewController1 = NewsFeedViewController()
    let bookStoreViewController = Storyboard.Books.instantiate(BookStoreViewController.self)
    let discoverViewController = DiscoverViewController()

    viewController1.tabBarItem = UITabBarItem(
      title: Strings.news().uppercased(),
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    discoverViewController.tabBarItem = UITabBarItem(
      title: Strings.discover().uppercased(),
      image: #imageLiteral(resourceName: "discover"),
      tag:2)
    bookStoreViewController.tabBarItem = UITabBarItem(
      title: Strings.books().uppercased(),
      image: #imageLiteral(resourceName: "books"),
      tag:3)

    // Set The View controller
    self.viewControllers = [
      UINavigationController(rootViewController: viewController1),
      UINavigationController(rootViewController: discoverViewController),
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
      #selector(self.didFinishBoarding(notification:)), name: AppNotification.didFinishBoarding, object: nil)
  }
  
  private func addObserversWhenNotVisible() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(register(notification:)), name: AppNotification.registrationSuccess, object: nil)
  }
  
  private func removeObserversWhenVisible() {
    NotificationCenter.default.removeObserver(self, name: AppNotification.registrationSuccess, object: nil)
  }
  
  // MARK: Helpers
  
  fileprivate func presentIntroductionOrSignInViewController() {
    displayOverlay()
    
    if GeneralSettings.sharedInstance.shouldShowIntroduction {
      let introductionVC = Storyboard.Introduction.instantiate(IntroductionViewController.self)
      let navigationController = UINavigationController(rootViewController: introductionVC)
      present(navigationController, animated: true, completion: nil)
    } else {
      let signInVC = Storyboard.Access.instantiate(SignInViewController.self)
      let navigationController = UINavigationController(rootViewController: signInVC)
      present(navigationController, animated: true, completion: nil)
    }
  }
  
  fileprivate func presentPenNameViewController(user: User) {
    let penNameViewController = Storyboard.Access.instantiate(PenNameViewController.self)
    penNameViewController.viewModel.initializeWith(user: user)
    let navigationController = UINavigationController(rootViewController: penNameViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  fileprivate func presentOnboardingViewController() {
    let onboardingViewController = OnBoardingViewController()
    let navigationController = UINavigationController(rootViewController: onboardingViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  fileprivate func refreshToOriginalState() {
    viewControllers?.forEach({ _ = ($0 as? UINavigationController)?.popToRootViewController(animated: false) })
    selectedIndex = 0
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
    refreshToOriginalState()
    UserManager.shared.deleteSignedInUser()
  }
  
  func signIn(notification: Notification) {
    showRootViewController()
  }
  
  func register(notification: Notification) {
    showRootViewController()
  }
  
  func didFinishBoarding(notification: Notification) {
    NotificationCenter.default.post(
      name: AppNotification.shouldRefreshData, object: nil)
    showRootViewController()
  }
  
  func showRootViewController() {
    self.dismiss(animated: true) {
      self.dismissOverlay()
    }
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
    overlayView.isHidden = false
    changeOverlayAlphaValue(animated: animated, alpha: 1)
  }
  
  func dismissOverlay(animated: Bool = true) {
    changeOverlayAlphaValue(animated: animated, alpha: 0) {
      self.overlayView.isHidden = true
    }
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
