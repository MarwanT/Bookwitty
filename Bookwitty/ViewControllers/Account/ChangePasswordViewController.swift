//
//  ChangePasswordViewController.swift
//  Bookwitty
//
//  Created by charles on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import SwiftLoader

class ChangePasswordViewController: UIViewController {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var currentPasswordInputField: PasswordInputField!
  @IBOutlet weak var newPasswordInputField: PasswordInputField!
  @IBOutlet var separators: [UIView]!
  @IBOutlet var changePasswordButton: UIButton!

  private let viewModel = ChangePasswordViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ChangePassword)
  }

  private func initializeComponents() {
    changePasswordButton.setTitle(Strings.change_password(), for: .normal)

    currentPasswordInputField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.current_password(),
      textFieldPlaceholder: Strings.current_password(),
      invalidationErrorMessage: "",
      returnKeyType: UIReturnKeyType.next,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    currentPasswordInputField.delegate = self

    currentPasswordInputField.validationBlock = { (password: String?) -> Bool in
      return !password.isEmptyOrNil()
    }

    newPasswordInputField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.new_password(),
      textFieldPlaceholder: Strings.new_password(),
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

    guard currentReult.isValid else {
      showErrorUpdatingPasswordAlert(error: Strings.current_password_is_empty_error())
      return
    }

    guard newResult.isValid else {
      if newPasswordInputField.textField.text.isEmptyOrNil() {
        showErrorUpdatingPasswordAlert(error: Strings.new_password_is_empty_error())
      } else if !(newPasswordInputField.textField.text?.isValidPassword() ?? false) {
        showErrorUpdatingPasswordAlert(error: Strings.password_minimum_characters_error())
      }
      return
    }

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .ChangePassword)
    Analytics.shared.send(event: event)

    let identifier: String = UserManager.shared.signedInUser.id ?? ""
    let current: String = currentReult.value ?? ""
    let new: String = newResult.value ?? ""
    SwiftLoader.show(animated: true)
    viewModel.updatePassword(identifier: identifier, current: current, new: new) {
      (success: Bool, error: Error?) in
      SwiftLoader.hide()
      if success {
        self.showSuccefullyUpdatedPasswordAlert()
      } else {
        self.currentPasswordInputField.status = .inValid
        self.newPasswordInputField.status = .inValid

        if let error = error {
          switch error {
          case BookwittyAPIError.invalidCurrentPassword:
            self.showErrorUpdatingPasswordAlert(error: Strings.password_is_wrong_error())
          default:
            self.showErrorUpdatingPasswordAlert(error: Strings.password_change_unknown_error())
          }
        }
      }
    }
  }

  fileprivate func showSuccefullyUpdatedPasswordAlert() {
    let alert = UIAlertController(title: nil, message: Strings.change_password_success(), preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: Strings.ok(), style: .default, handler: { _ in
      _ = self.navigationController?.popViewController(animated: true)
    }))
    self.navigationController?.present(alert, animated: true, completion: nil)
  }

  fileprivate func showErrorUpdatingPasswordAlert(error message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Strings.ok(), style: .default, handler: nil))
    self.navigationController?.present(alert, animated: true, completion: nil)
  }
}

//MARK: - Themable implementation
extension ChangePasswordViewController: Themeable {
  func applyTheme() {

    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    stackViewBackgroundView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }

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

//MARK: - Localizable implementation
extension ChangePasswordViewController: Localizable {
  func applyLocalization() {
    title = Strings.change_password()

    changePasswordButton.setTitle(Strings.change_password(), for: .normal)

    currentPasswordInputField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.current_password(),
      textFieldPlaceholder: Strings.current_password(),
      invalidationErrorMessage: "",
      returnKeyType: UIReturnKeyType.next,
      autocorrectionType: .no,
      autocapitalizationType: .none)
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
