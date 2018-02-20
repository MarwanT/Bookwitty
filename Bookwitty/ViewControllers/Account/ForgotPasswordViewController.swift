//
//  ForgotPasswordViewController.swift
//  Bookwitty
//
//  Created by charles on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet var separators: [UIView]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ForgotYourPassword)
  }

  private func initializeComponents() {
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
    let event: Analytics.Event = Analytics.Event(category: .Author,
                                                 action: .ResetPassword)
    Analytics.shared.send(event: event)

    let emailValidationResult = emailField.validateField()
    guard let email: String = emailValidationResult.value, !email.isBlank else {
      showErrorDialogMessage(errorMessage: Strings.email_empty())
      return
    }
    guard emailValidationResult.isValid else {
      showErrorDialogMessage(errorMessage: Strings.email_invalid())
      return
    }

    _ = UserAPI.resetPassword(email: email) {
      (success: Bool, error: BookwittyAPIError?) in
      if success {
        let alertController = UIAlertController(title: nil, message: Strings.reset_password_text(), preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: Strings.ok(), style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
      } else {
        self.showErrorDialogMessage(errorMessage: Strings.some_thing_wrong_error())
      }
    }
  }

  fileprivate func showErrorDialogMessage(errorMessage: String, dimissButtonTitle: String = Strings.ok()) {
    let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: dimissButtonTitle, style: UIAlertActionStyle.default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
}

//MARK: - Themable implementation
extension ForgotPasswordViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    stackViewBackgroundView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }

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

//MARK: - Localizable implementation
extension ForgotPasswordViewController: Localizable {
  func applyLocalization() {
    title = Strings.forgot_password()

    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.email(),
      textFieldPlaceholder: Strings.enter_your_email(),
      invalidationErrorMessage: Strings.email_invalid(),
      returnKeyType: UIReturnKeyType.send,
      keyboardType: .emailAddress,
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
