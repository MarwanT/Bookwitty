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
    self.title = Strings.change_password()
    initializeComponents()
    applyTheme()

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
      return password?.isValidPassword() ?? false
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

    guard currentReult.isValid && newResult.isValid else {
      return
    }

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .ChangePassword)
    Analytics.shared.send(event: event)

    let identifier: String = UserManager.shared.signedInUser.id ?? ""
    let current: String = currentReult.value ?? ""
    let new: String = newResult.value ?? ""

    viewModel.updatePassword(identifier: identifier, current: current, new: new) {
      (success: Bool, error: Error?) in
      if success {
        let alert = UIAlertController(title: "Success", message: "Password Changes Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
      } else {
        self.currentPasswordInputField.status = .inValid
        self.newPasswordInputField.status = .inValid
      }
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

