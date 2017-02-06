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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Apply theme here for it will be changed by the
    // selected tutorial view controller page later
    applyTheme()
    
    applyLocalization()
    
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
  
  
  // MARK: - Actions
  
  @IBAction func registerButtonTap(_ sender: UIButton) {
    let signInViewController = Storyboard.Access.instantiate(RegisterViewController.self)
    self.navigationController?.pushViewController(signInViewController, animated: true)
  }
  
  @IBAction func signInButtonTap(_ sender: UIButton) {
    let signInViewController = Storyboard.Access.instantiate(SignInViewController.self)
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
