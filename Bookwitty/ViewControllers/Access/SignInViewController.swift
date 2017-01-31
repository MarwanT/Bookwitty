//
//  SignInViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var informationLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()
  }
  
  /// Do the required setup
  private func awakeSelf() {
    title = "Signin"
    
    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: "Email", textFieldPlaceholder: "Enter your email",
      invalidationErrorMessage: "Oooops your email seems to be invalid",
      returnKeyType: UIReturnKeyType.continue)
    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: "Password", textFieldPlaceholder: "Enter your password",
      invalidationErrorMessage: "Oooops your password seems to be invalid",
      returnKeyType: UIReturnKeyType.done)
    
    emailField.validationBlock = emailValidation
    passwordField.validationBlock =  passwordValidation
  }
  
  func emailValidation(email: String?) -> Bool {
    // TODO: Add email validation logic
    return true
  }
  
  func passwordValidation(password: String?) -> Bool {
    // TODO: Add password validation logic
    return false
  }
}

extension SignInViewController: Themeable {
  func applyTheme() {
    stackView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()
    signInButton.setTitle("Signin", for: .normal)
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: signInButton)
  }
}
