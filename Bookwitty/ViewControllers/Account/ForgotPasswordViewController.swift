//
//  ForgotPasswordViewController.swift
//  Bookwitty
//
//  Created by charles on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var submitButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
  }

  private func initializeComponents() {
    title = Strings.forgot_password()

    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.email(),
      textFieldPlaceholder: Strings.enter_your_email(),
      invalidationErrorMessage: Strings.email_invalid(),
      returnKeyType: UIReturnKeyType.send,
      keyboardType: .emailAddress,
      autocorrectionType: .no,
      autocapitalizationType: .none)
    
    emailField.delegate = self
    emailField.validationBlock = blockForEmailValidation()

    submitButton.setTitle(Strings.reset_password(), for: UIControlState.normal)
  }

  private func blockForEmailValidation() -> (String?) -> Bool {
    return { (email: String?) -> Bool in
      email?.isValidEmail() ?? false
    }
  }

  fileprivate func resetPassword() {
    let emailValidationResult = emailField.validateField()
    if emailValidationResult.isValid, let email: String = emailValidationResult.value {
      _ = UserAPI.resetPassword(email: email) {
        (success: Bool, error: BookwittyAPIError?) in
      }
    }
  }
}

//MARK: - Themable implementation
extension ForgotPasswordViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: submitButton)
  }
}

//MARK: - IBActions
extension ForgotPasswordViewController {
  @IBAction fileprivate func submitButtonTouchUpInside(_ sender: UIButton) {
    resetPassword()
  }
}

// MARK: - Input fields delegate
extension ForgotPasswordViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    if inputField === emailField {
      resetPassword()
    }
    return true
  }
}
