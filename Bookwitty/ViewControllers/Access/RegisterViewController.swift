//
//  RegisterViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var firstNameField: InputField!
  @IBOutlet weak var lastNameField: InputField!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var countryField: InformativeInputField!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var termsLabel: UILabel!
  @IBOutlet var separators: [UIView]!

  let viewModel: RegisterViewModel = RegisterViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
  }

  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.viewControllerTitle

    firstNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.firstNameDescriptionLabelText,
      textFieldPlaceholder: viewModel.firstNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.firstNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue)

    lastNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.lastNameDescriptionLabelText,
      textFieldPlaceholder: viewModel.lastNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.lastNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue)

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

    countryField.configuration = InputFieldConfiguration(
      textFieldPlaceholder: viewModel.countryTextFieldPlaceholderText,
      returnKeyType: UIReturnKeyType.default)

    emailField.validationBlock = emailValidation
    passwordField.validationBlock = passwordValidation
    firstNameField.validationBlock = notEmptyValidation
    lastNameField.validationBlock = notEmptyValidation

    emailField.delegate = self
    passwordField.delegate = self
    firstNameField.delegate = self
    lastNameField.delegate = self
  }

  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    let emailValidationResult = emailField.validateField()
    let passwordValidationResult = passwordField.validateField()
    let firstNameValidationResult = firstNameField.validateField()
    let lastNameValidationResult = lastNameField.validateField()
    if(!emailValidationResult.isValid || !passwordValidationResult.isValid
      || !firstNameValidationResult.isValid || !lastNameValidationResult.isValid) {
      // TODO: Display error message
    } else {
      // TODO: Proceed all good
    }
  }

  func emailValidation(email: String?) -> Bool {
    return email?.isValidEmail() ?? false
  }

  func passwordValidation(password: String?) -> Bool {
    return password?.isValidPassword() ?? false
  }

  func notEmptyValidation(text: String?) -> Bool {
    return text?.isValidText() ?? false
  }
}

extension RegisterViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    switch inputField {
    case firstNameField:
      return lastNameField.becomeFirstResponder()
    case lastNameField:
      return emailField.becomeFirstResponder()
    case emailField:
      return passwordField.becomeFirstResponder()
    case passwordField:
      return passwordField.resignFirstResponder()
    default:
      return true
    }
  }
}
