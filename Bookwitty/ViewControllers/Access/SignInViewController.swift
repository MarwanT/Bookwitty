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
  
  let viewModel: SignInViewModel = SignInViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()
  }
  
  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.signInButtonTitle
    
    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.emailDescriptionLabelText,
      textFieldPlaceholder: viewModel.emailTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.emailInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue)
    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.passwordDescriptionLabelText,
      textFieldPlaceholder: viewModel.passwordTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.passwordInvalidationErrorMessage,
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
    signInButton.setTitle(viewModel.signInButtonTitle, for: .normal)
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: signInButton)
    stackViewBackgroundView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    
    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }
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
