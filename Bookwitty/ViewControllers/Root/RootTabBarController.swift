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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeTabBarViewControllers()
    applyTheme()
    addObservers()
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
    if UserManager.shared.isSignedIn {
      //TODO: Post shouldRefreshData Notification
    }
  }
  
  private func initializeTabBarViewControllers() {
    let newsFeedViewController = UserManager.shared.isSignedIn ? NewsFeedViewController() : JoinUsNode().viewController()
    let bookStoreViewController = Storyboard.Books.instantiate(BookStoreViewController.self)
    let discoverViewController = DiscoverViewController()
    let bagViewController = BagViewController()

    newsFeedViewController.tabBarItem = UITabBarItem(
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
      UINavigationController(rootViewController: newsFeedViewController),
      UINavigationController(rootViewController: discoverViewController),
      UINavigationController(rootViewController: bookStoreViewController),
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
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.callToActionHandler(notification:)), name: AppNotification.callToAction, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.shouldDisplayRegistration(notification:)), name: AppNotification.shouldDisplayRegistration, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.shouldDisplaySignIn(notification:)), name: AppNotification.shouldDisplaySignIn, object: nil)
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
  
  fileprivate func refreshTabBarViewController() {
    guard let newsNavigationController = viewControllers?.first as? UINavigationController else {
      return
    }
    let newsFeedViewController = UserManager.shared.isSignedIn ? NewsFeedViewController() : JoinUsNode().viewController()
    newsFeedViewController.tabBarItem = UITabBarItem(
      title: Strings.news().uppercased(),
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    newsNavigationController.viewControllers.replaceSubrange(0...0, with: [newsFeedViewController])
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
  func shouldDisplaySignIn(notification: Notification?) {
    presentSignInViewController()
  }

  func shouldDisplayRegistration(notification: Notification?) {
    presentRegisterViewController()
  }

  func callToActionHandler(notification: Notification?) {
    guard !UserManager.shared.isSignedIn else {
      //If user is signed-in => do nothing
      return
    }
    //Call-To-Action Value
    let cta = notification?.object as? CallToAction
    //Display Alert accordingly
    dispalyUserNotSignedInAlert(cta: cta)
  }

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
    UserManager.shared.deleteSignedInUser()
    refreshTabBarViewController()
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

  func presentRegisterViewController() {
    let registerVC = Storyboard.Access.instantiate(RegisterViewController.self)
    let navigationController = UINavigationController(rootViewController: registerVC)
    present(navigationController, animated: true, completion: nil)
  }

  func presentSignInViewController() {
    let signInVC = Storyboard.Access.instantiate(SignInViewController.self)
    let navigationController = UINavigationController(rootViewController: signInVC)
    present(navigationController, animated: true, completion: nil)
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

  fileprivate func dispalyUserNotSignedInAlert(cta: CallToAction?) {
    let alertController = UIAlertController(
      title: Strings.user_not_signed_in_alert_title(),
      message: Strings.user_not_signed_in_alert_message(),
      preferredStyle: .actionSheet)
    let signInAction = UIAlertAction(
      title: Strings.sign_in(),
      style: UIAlertActionStyle.default) { _ in
        //TODO: handle Action
        self.presentSignInViewController()
    }

    let registerAction = UIAlertAction(
      title: Strings.register(),
      style: UIAlertActionStyle.default) { _ in
        //TODO: handle Action
        self.presentRegisterViewController()
    }

    let neutralAction = UIAlertAction(
      title: Strings.account_needs_confirmation_alert_dismiss_button_title(),
      style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(signInAction)
    alertController.addAction(registerAction)
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
