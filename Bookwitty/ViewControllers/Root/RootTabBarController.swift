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
    setupCenterButton()
    self.delegate = self
    navigationItem.backBarButtonItem = UIBarButtonItem.back
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
      if UserManager.shared.shouldEditPenName {
        presentPenNameViewController(user: UserManager.shared.signedInUser)
      } else if UserManager.shared.shouldDisplayOnboarding {
        presentOnboardingViewController()
      }
    }
  }
  
  private func setupCenterButton() {
    let button = UIButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    //Constraints
    self.tabBar.addSubview(button)
    button.addWidthConstraint(44.0)
    button.addHeightConstraint(44.0)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor)
      ])
    
    button.setImage(#imageLiteral(resourceName: "contentCreation"), for: .normal)
    button.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    button.center = self.tabBar.center
    button.isUserInteractionEnabled = false
  }
  
  private func initializeTabBarViewControllers() {
    let newsFeedViewController = newsFeedViewControllerCreator()
    let bookStoreViewController = Storyboard.Books.instantiate(BookStoreViewController.self)
    let emptyViewController = UIViewController()
    let discoverViewController = DiscoverViewController()
    let settingsViewController = accountControllerCreator()

    newsFeedViewController.viewController.tabBarItem = UITabBarItem(
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
    emptyViewController.tabBarItem = UITabBarItem(
      title: "",
      image: nil,
      tag:4)
    settingsViewController.viewController.tabBarItem = UITabBarItem(
      title: Strings.me().uppercased(),
      image: #imageLiteral(resourceName: "person"),
      tag:4)
    
    // Set The View controller
    self.viewControllers = [
      UINavigationController(rootViewController: newsFeedViewController.viewController),
      UINavigationController(rootViewController: discoverViewController),
      EmptyNavigationViewController(rootViewController: emptyViewController),
      UINavigationController(rootViewController: bookStoreViewController),
      UINavigationController(rootViewController: settingsViewController.viewController),
    ]
    
    // Hide navigation bar for news feed if necessary
    newsFeedViewController.viewController.navigationController?.setNavigationBarHidden(newsFeedViewController.hideNavigationBar, animated: true)
    settingsViewController.viewController.navigationController?.setNavigationBarHidden(settingsViewController.hideNavigationBar, animated: true)
    
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
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.tooManyRequests(notification:)), name: AppNotification.tooManyRequests, object: nil)
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.serverBusy(notification:)), name: AppNotification.serverIsBusy, object: nil)
  }
  
  private func addObserversWhenNotVisible() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(register(notification:)), name: AppNotification.registrationSuccess, object: nil)
  }
  
  private func removeObserversWhenVisible() {
    NotificationCenter.default.removeObserver(self, name: AppNotification.registrationSuccess, object: nil)
  }
  
  // MARK: Helpers
  fileprivate func newsFeedViewControllerCreator() -> (viewController: UIViewController, hideNavigationBar: Bool) {
    let viewController: UIViewController
    let hideNavigationBar: Bool
    
    if UserManager.shared.isSignedIn {
      viewController = NewsFeedViewController()
      hideNavigationBar = false
    } else {
      let getStartedNode = GetStarted()
      getStartedNode.getStartedText = Strings.get_started_newsfeed_text()
      viewController = getStartedNode.genericViewController
      hideNavigationBar = false
    }
    
    // Add search button
    viewController.navigationItem.rightBarButtonItems = searchBarButton()
    
    return (viewController, hideNavigationBar)
  }

  fileprivate func accountControllerCreator() -> (viewController: UIViewController, hideNavigationBar: Bool) {
    let viewController: UIViewController
    let hideNavigationBar: Bool

    if UserManager.shared.isSignedIn {
      viewController = Storyboard.Account.instantiate(AccountViewController.self)
      hideNavigationBar = false
    } else {
      let getStartedNode = GetStarted()
      getStartedNode.getStartedText = Strings.get_started_account_text()
      viewController = getStartedNode.genericViewController
      hideNavigationBar = false
    }

    return (viewController, hideNavigationBar)
  }

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
    penNameViewController.mode = .Edit
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

    defer {
      NotificationCenter.default.post(name: AppNotification.authenticationStatusChanged, object: nil, userInfo: [AppNotification.Key.status : UserManager.shared.isSignedIn])
    }

    guard let newsNavigationController = viewControllers?.first as? UINavigationController else {
      return
    }

    let newsFeedViewController = newsFeedViewControllerCreator()
    newsFeedViewController.viewController.tabBarItem = UITabBarItem(
      title: Strings.news().uppercased(),
      image: #imageLiteral(resourceName: "newsfeed"),
      tag: 1)
    
    newsNavigationController.setNavigationBarHidden(newsFeedViewController.hideNavigationBar, animated: true)
    newsNavigationController.viewControllers.replaceSubrange(0...0, with: [newsFeedViewController.viewController])

    guard let settingsNavigationController = viewControllers?.last as? UINavigationController else {
      return
    }

    let settingsViewController = accountControllerCreator()
    settingsViewController.viewController.tabBarItem = UITabBarItem(
      title: Strings.me(),
      image: #imageLiteral(resourceName: "person"),
      tag:4)
    
    settingsViewController.viewController.navigationController?.setNavigationBarHidden(settingsViewController.hideNavigationBar, animated: true)
    settingsNavigationController.viewControllers.replaceSubrange(0...0, with: [settingsViewController.viewController])
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
    UserManager.shared.didOpenOnboarding = false
    refreshTabBarViewController()
  }
  
  func signIn(notification: Notification) {
    if(UserManager.shared.shouldDisplayOnboarding) {
      presentedViewController?.dismiss(animated: true)
    } else {
      showRootViewController()
    }
  }
  
  func register(notification: Notification) {
    showRootViewController()
  }
  
  func didFinishBoarding(notification: Notification) {
    NotificationCenter.default.post(
      name: AppNotification.shouldRefreshData, object: nil)
    showRootViewController()
  }
  
  func tooManyRequests(notification: Notification?) {
    //TODO: handle server error `too many requests`
  }

  func serverBusy(notification: Notification?) {
    displayServerBusyAlert()
  }

  func showRootViewController() {
    self.dismiss(animated: true,completion: {
      self.refreshTabBarViewController()
    })
  }

  func presentRegisterViewController() {
    let registerVC = Storyboard.Access.instantiate(RegisterViewController.self)
    let navigationController = UINavigationController(rootViewController: registerVC)
    registerVC.navigationItem.leftBarButtonItem = cancelBarButton()
    present(navigationController, animated: true, completion: nil)
  }

  func presentSignInViewController() {
    let signInVC = Storyboard.Access.instantiate(SignInViewController.self)
    let navigationController = UINavigationController(rootViewController: signInVC)
    signInVC.navigationItem.leftBarButtonItem = cancelBarButton()
    present(navigationController, animated: true, completion: nil)
  }

  private func cancelBarButton() -> UIBarButtonItem {
    return UIBarButtonItem(
      title: Strings.cancel(),
      style: UIBarButtonItemStyle.plain,
      target: self,
      action: #selector(self.cancelBarButtonTouchUpInside(_:)))
  }

  func cancelBarButtonTouchUpInside(_ sender: Any?) {
    self.dismiss(animated: true, completion: nil)
  }

  func searchBarButton() -> [UIBarButtonItem] {
    let rightNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    rightNegativeSpacer.width = -10
    let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.searchButtonTap(_:)))
    return [rightNegativeSpacer, searchBarButton]
  }

  func searchButtonTap(_ sender: UIBarButtonItem?) {
    guard let newsNavigationController = viewControllers?.first as? UINavigationController else {
      return
    }
    let searchVC = SearchViewController()
    searchVC.hidesBottomBarWhenPushed = true
    newsNavigationController.pushViewController(searchVC, animated: true)
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

  fileprivate func displayServerBusyAlert() {
    let alertController = UIAlertController(
      title: Strings.some_thing_wrong_error(), //TODO: Localize
      message: Strings.try_again(), //TODO: Localize
      preferredStyle: .alert)
    let neutralAction = UIAlertAction(
      title: Strings.ok(),
      style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(neutralAction)
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - Misfortune Node Delegate
extension RootTabBarController: MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?) {
    guard let action = action else {
      return
    }
    
    switch action {
    case .updateApp:
      if let mode = node.mode {
        if case MisfortuneNode.Mode.appNeedsUpdate(let url) = mode {
          openURL(url: url)
        }
      }
    default:
      break
    }
  }
}

extension RootTabBarController: UITabBarControllerDelegate {
  
  func isUserSignedIn() -> Bool {
    return UserManager.shared.isSignedIn
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {    
    if viewController is EmptyNavigationViewController {
      guard UserManager.shared.isSignedIn else {
        //If user is not signed In post notification and do not fall through
        NotificationCenter.default.post( name: AppNotification.callToAction, object: nil)
        return false
      }
      let post: CandidatePost = Text()
      self.presentContentEditor(with: post)
      return false
    }
    return true
  }
}
