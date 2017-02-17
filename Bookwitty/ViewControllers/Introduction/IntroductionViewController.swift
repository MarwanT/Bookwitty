//
//  IntroductionViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

class IntroductionViewController: UIViewController {
  let viewModel = IntroductionViewModel()
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var tutorialContainer: UIView!
  
  var shouldDisplayRegisterVC: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Apply theme here for it will be changed by the
    // selected tutorial view controller page later
    applyTheme()
    
    applyLocalization()
    
    registerNotifications()
    
    let tutorialViewController = Storyboard.Introduction.instantiate(TutorialViewController.self)
    tutorialViewController.tutorialDelegate = self
    tutorialViewController.viewModel.tutorialPageData = viewModel.tutorialData
    let tutorialChildView = add(asChildViewController: tutorialViewController, toView: tutorialContainer)
    tutorialChildView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: tutorialChildView.superview!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if shouldDisplayRegisterVC {
      shouldDisplayRegisterVC = false
      pushRegisterViewController()
    }
  }
  
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handlerRegisterFromSignInNotification(_:)),
      name: AppNotification.introductionShouldDisplayRegistration, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Actions
  
  @IBAction func registerButtonTap(_ sender: UIButton) {
    pushRegisterViewController()
  }
  
  @IBAction func signInButtonTap(_ sender: UIButton) {
    pushSignInViewController()
  }
  
  func handlerRegisterFromSignInNotification(_ notification: Notification) {
    shouldDisplayRegisterVC = true
    _ = navigationController?.popViewController(animated: true)
  }
  
  // MARK: Helpers
  func pushRegisterViewController() {
    let registerViewController = Storyboard.Access.instantiate(RegisterViewController.self)
    self.navigationController?.pushViewController(registerViewController, animated: true)
  }
  
  func pushSignInViewController() {
    let signInViewController = Storyboard.Access.instantiate(SignInViewController.self)
    signInViewController.viewModel.registerNotificationName = AppNotification.introductionShouldDisplayRegistration
    self.navigationController?.pushViewController(signInViewController, animated: true)
  }
}

extension IntroductionViewController: TutorialViewControllerDelegate {
  func tutorialViewController(_ tutorialViewController: TutorialViewController, didSelectPageAtIndex index: Int) {
    guard let buttonsColor = viewModel.colorForIndex(index: index) else {
      return
    }
    
    UIView.animate(withDuration: 0.34) {
      self.changeButtonsColors(withColor: buttonsColor)
      self.view.backgroundColor = buttonsColor
    }
  }
}

extension IntroductionViewController: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: signInButton)
    ThemeManager.shared.currentTheme.styleSecondaryButton(button: registerButton)
  }
  
  func changeButtonsColors(withColor color: UIColor) {
    ThemeManager.shared.currentTheme.stylePrimaryButton(
      button: self.signInButton,
      withColor: color,
      highlightedColor: color)
    ThemeManager.shared.currentTheme.styleSecondaryButton(
      button: self.registerButton, withColor: color,
      highlightedColor: color)
  }
}

extension IntroductionViewController: Localizable {
  func applyLocalization() {
    signInButton.setTitle(viewModel.signInButtonTitle, for: .normal)
    registerButton.setTitle(viewModel.registerButtonTitle, for: .normal)
  }
}
