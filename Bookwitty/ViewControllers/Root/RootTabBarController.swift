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
    let bagViewController = BagViewController()

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
    bagViewController.tabBarItem = UITabBarItem(
      title: Strings.bag().uppercased(),
      image: #imageLiteral(resourceName: "emptyBasket"),
      tag:3)

    // Set The View controller
    self.viewControllers = [
      UINavigationController(rootViewController: viewController1),
      UINavigationController(rootViewController: discoverViewController),
      UINavigationController(rootViewController: bookStoreViewController),
      UINavigationController(rootViewController: bagViewController),
    ]
    
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
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.handleRefreshTokenFailure(notification:)), name: AppNotification.failToRefreshToken, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.checkAppStatus(notification:)), name: AppNotification.didCheckAppStatus, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.accountNeedsConfirmation(notification:)), name: AppNotification.accountNeedsConfirmation, object: nil)
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
    penNameViewController.viewModel.initializeWith(penName: user.penNames?.first, andUser: user)
    let navigationController = UINavigationController(rootViewController: penNameViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  fileprivate func presentOnboardingViewController() {
    let onboardingViewController = OnBoardingViewController()
    let navigationController = UINavigationController(rootViewController: onboardingViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  fileprivate func refreshToOriginalState() {
    initializeTabBarViewControllers()
  }
  
  fileprivate func displayAppNeedsUpdate(with updateURL: URL?) {
    let forceUpdateNode = MisfortuneNode(mode: MisfortuneNode.Mode.appNeedsUpdate(updateURL))
    forceUpdateNode.delegate = self
    let forceUpdateViewController = GenericNodeViewController(
      node: forceUpdateNode,
      title: nil,
      scrollableContentIfNeeded: false)
    self.present(forceUpdateViewController, animated: true, completion: nil)
  }
  
  fileprivate func openURL(url: URL?) {
    guard let url = url else {
      return
    }
    UIApplication.shared.openURL(url)
  }
}

// MARK: - Themeable
extension RootTabBarController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

//MARK: - Actions
extension RootTabBarController {
  fileprivate func sendConfirmationEmail() {
    _ = GeneralAPI.sendAccountConfirmation {
      (success, error) in
      print("Account confirmation \(success)")
    }
  }
}

//MARK: - Notifications
extension RootTabBarController {
  func accountNeedsConfirmation(notification: Notification?) {
    displayAccountNeedsConfirmationAlert()
  }
  
  func checkAppStatus(notification: Notification) {
    switch AppManager.shared.appStatus {
    case .needsUpdate(let updateURL):
      displayAppNeedsUpdate(with: updateURL)
    case .valid: fallthrough
    case .unspecified: fallthrough
    default:
      break // Everyone lives happily ever after
    }
  }
  
  func handleRefreshTokenFailure(notification: Notification) {
    displayFailToRefreshTokenAlert()
  }
  
  func signOut(notificaiton: Notification?) {

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .SignOut)
    Analytics.shared.send(event: event)

    AccessToken.shared.deleteToken()
    presentIntroductionOrSignInViewController()
    UserManager.shared.deleteSignedInUser()
    refreshToOriginalState()
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

// MARK: - Alerts
extension RootTabBarController {
  fileprivate func displayFailToRefreshTokenAlert() {
    let alertController = UIAlertController(
      title: Strings.fail_to_refresh_token_alert_title(),
      message: Strings.fail_to_refresh_token_alert_message(),
      preferredStyle: .alert)
    let okAction = UIAlertAction(
      title: Strings.ok(),
      style: UIAlertActionStyle.default) { _ in
        self.signOut(notificaiton: nil)
    }
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  fileprivate func displayAccountNeedsConfirmationAlert() {
    let alertController = UIAlertController(
      title: Strings.account_needs_confirmation_alert_title(),
      message: Strings.account_needs_confirmation_alert_message(),
      preferredStyle: .alert)
    let resendAction = UIAlertAction(
      title: Strings.account_needs_confirmation_alert_resend_confirmation_button_title(),
      style: UIAlertActionStyle.default) { _ in
        self.sendConfirmationEmail()
    }
    let neutralAction = UIAlertAction(
      title: Strings.account_needs_confirmation_alert_dismiss_button_title(),
      style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(resendAction)
    alertController.addAction(neutralAction)
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - Misfortune Node Delegate
extension RootTabBarController: MisfortuneNodeDelegate {
  func misfortuneNodeDidTapActionButton(node: MisfortuneNode, mode: MisfortuneNode.Mode) {
    switch mode {
    case .appNeedsUpdate(let updateURL):
      openURL(url: updateURL)
    default:
      break
    }
  }
  
  func misfortuneNodeDidTapSettingsButton(node: MisfortuneNode, mode: MisfortuneNode.Mode) {}
}
