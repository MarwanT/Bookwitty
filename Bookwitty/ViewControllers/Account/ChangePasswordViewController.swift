//
//  ChangePasswordViewController.swift
//  Bookwitty
//
//  Created by charles on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

  @IBOutlet weak var currentPasswordInputField: PasswordInputField!
  @IBOutlet weak var newPasswordInputField: PasswordInputField!
  @IBOutlet var changePasswordButton: UIButton!

  private let viewModel = ChangePasswordViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.title = viewModel.changePasswordText
    initializeComponents()
    applyTheme()
  }

  private func initializeComponents() {
    changePasswordButton.setTitle(viewModel.changePasswordText, for: .normal)

    currentPasswordInputField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.currentPasswordText,
      textFieldPlaceholder: viewModel.currentPasswordText,
      invalidationErrorMessage: "",
      returnKeyType: UIReturnKeyType.next,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    currentPasswordInputField.delegate = self

    currentPasswordInputField.validationBlock = { (password: String?) -> Bool in
      return password?.isValidPassword() ?? false
    }

    newPasswordInputField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.newPasswordText,
      textFieldPlaceholder: viewModel.newPasswordText,
      invalidationErrorMessage: "",
      returnKeyType: UIReturnKeyType.done,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    newPasswordInputField.validationBlock = { (password: String?) -> Bool in
      return password?.isValidPassword() ?? false
    }

    newPasswordInputField.delegate = self
  }

  fileprivate func initiateChangePassword() {

    let currentReult = currentPasswordInputField.validateField()
    let newResult = newPasswordInputField.validateField()

    guard currentReult.isValid && newResult.isValid else {
      return
    }

  }
}

//MARK: - Themable implementation
extension ChangePasswordViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: changePasswordButton)
  }
}

//MARK: - IBActions
extension ChangePasswordViewController {
  @IBAction func changePasswordButtonTouchUpInside(_ sender: UIButton) {
    initiateChangePassword()
  }
}


//MARK: - InputFieldDelegate implementation
extension ChangePasswordViewController: InputFieldDelegate {
  func inputFieldShouldReturn(inputField: InputField) -> Bool {
    if inputField === currentPasswordInputField {
      let _ = newPasswordInputField.becomeFirstResponder()
    } else if inputField === newPasswordInputField {
      initiateChangePassword()
    }
    return true
  }
}

