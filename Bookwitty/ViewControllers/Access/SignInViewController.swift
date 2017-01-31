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
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var informationLabel: UILabel!
  
  @IBOutlet var separators: [UIView]!
  
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
    passwordField.validationBlock = passwordValidation

    emailField.delegate = self
    passwordField.delegate = self
    
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
  }
  
  func emailValidation(email: String?) -> Bool {
    return email?.isValidEmail() ?? false
  }
  
  func passwordValidation(password: String?) -> Bool {
    let minimumNumberOfCharacters = 6
    guard let password = password, !password.isEmpty else {
      return false
    }
    return password.characters.count > minimumNumberOfCharacters
  }
  
  
  @IBAction func signInButtonTouchUpInside(_ sender: Any) {
    let emailValidationResult = emailField.validateField()
    let passwordValidationResult = passwordField.validateField()
    
    if emailValidationResult.isValid && passwordValidationResult.isValid {
      // TODO: Proceed with Sign proceedures
    } else {
      // TODO: Display error message
    }
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

extension SignInViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    switch inputField {
    case emailField:
      return passwordField.becomeFirstResponder()
    case passwordField:
      return passwordField.resignFirstResponder()
    default:
      return true
    }
  }
}
