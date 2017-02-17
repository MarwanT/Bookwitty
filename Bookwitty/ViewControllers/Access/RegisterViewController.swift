//
//  RegisterViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import EMCCountryPickerController
import TTTAttributedLabel

class RegisterViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var firstNameField: InputField!
  @IBOutlet weak var lastNameField: InputField!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var countryField: InformativeInputField!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var termsLabel: TTTAttributedLabel!
  @IBOutlet var separators: [UIView]!

  @IBOutlet weak var scrollViewBottomToLabelTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!

  let viewModel: RegisterViewModel = RegisterViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    navigationController?.navigationBar.backItem?.title = ""
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.view.endEditing(true)
  }

  private func setupAttributedTexts() {
    //Set Attributed Styled up Text
    termsLabel.attributedText = viewModel.styledTermsOfUseAndPrivacyPolicyText()
    //Attributed Label Links Styling
    termsLabel.linkAttributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()

    let termsOfUseRange: NSRange = (termsLabel.attributedText.string as NSString).range(of: viewModel.termsOfUseText)
    let privacyPolicyRange: NSRange = (termsLabel.attributedText.string as NSString).range(of: viewModel.privacyPolicyText)

    //Add click link identifiers
    termsLabel.addLink(to: AttributedLinkReference.termsOfUse.url, with: termsOfUseRange)
    termsLabel.addLink(to: AttributedLinkReference.privacyPolicy.url, with: privacyPolicyRange)

    //Set Delegates
    termsLabel.delegate = self
  }

  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.viewControllerTitle

    setupAttributedTexts()

    firstNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.firstNameDescriptionLabelText,
      textFieldPlaceholder: viewModel.firstNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.firstNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    lastNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.lastNameDescriptionLabelText,
      textFieldPlaceholder: viewModel.lastNameTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.lastNameInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.emailDescriptionLabelText,
      textFieldPlaceholder: viewModel.emailTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.emailInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.continue,
      keyboardType: .emailAddress,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.passwordDescriptionLabelText,
      textFieldPlaceholder: viewModel.passwordTextFieldPlaceholderText,
      invalidationErrorMessage: viewModel.passwordInvalidationErrorMessage,
      returnKeyType: UIReturnKeyType.done)

    countryField.configuration = InputFieldConfiguration(
      descriptionLabelText: viewModel.countryDescriptionLabelText,
      textFieldPlaceholder: viewModel.countryTextFieldPlaceholderText,
      returnKeyType: UIReturnKeyType.default)

    countryField.text = viewModel.country?.name ?? ""

    emailField.validationBlock = emailValidation()
    passwordField.validationBlock = passwordValidation()
    firstNameField.validationBlock = notEmptyValidation()
    lastNameField.validationBlock = notEmptyValidation()

    emailField.delegate = self
    passwordField.delegate = self
    firstNameField.delegate = self
    lastNameField.delegate = self

    countryField.informativeInputFieldDelegate = self

    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    stackView.spacing = 10

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(RegisterViewController.keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(RegisterViewController.keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }


  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    let emailValidationResult = emailField.validateField()
    let passwordValidationResult = passwordField.validateField()
    let firstNameValidationResult = firstNameField.validateField()
    let lastNameValidationResult = lastNameField.validateField()
    if(emailValidationResult.isValid && passwordValidationResult.isValid
      && firstNameValidationResult.isValid && lastNameValidationResult.isValid) {
      let email = emailValidationResult.value!
      let password = passwordValidationResult.value!
      let firstName = firstNameValidationResult.value!
      let lastName = lastNameValidationResult.value!
      let country = viewModel.country!.code

      viewModel.registerUserWithData(firstName: firstName, lastName: lastName, email: email, country: country, password: password, completionBlock: { (success: Bool, user: User?, error: BookwittyAPIError?) in
        if let user = user, success {
          NotificationCenter.default.post(name: AppNotification.registrationSuccess, object: user)
        } else if let error = error {
          switch(error) {
          case BookwittyAPIError.emailAlreadyExists:
            self.showAlertErrorWith(title: self.viewModel.ooopsText, message: self.viewModel.emailAlreadyExistsErrorText)
          default: break
          }
        } else {
          self.showAlertErrorWith(title: self.viewModel.ooopsText, message: self.viewModel.somethingWentWrongText)
        }
      })
    } else {
      NotificationView.show(notificationMessages:
        [
          NotificationMessage(text: viewModel.registerErrorInFieldsNotification)
        ]
      )

    }
  }

  func showAlertErrorWith(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: viewModel.okText, style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  func emailValidation() -> (_ email: String?) -> Bool {
    return { (email) -> Bool in
      return email?.isValidEmail() ?? false
    }
  }

  func passwordValidation() -> (_ password: String?) -> Bool {
    return { (password) -> Bool in
      return password?.isValidPassword() ?? false
    }
  }

  func notEmptyValidation() -> (_ text: String?) -> Bool {
    return { (text) -> Bool in
      return text?.isValidText() ?? false
    }
  }

  // MARK: - Keyboard Handling
  func keyboardWillShow(_ notification: NSNotification) {

    if let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let frame = value.cgRectValue
      scrollViewBottomToSuperviewBottomConstraint.constant = -frame.height
    }

    self.view.removeConstraint(scrollViewBottomToLabelTopConstraint)
    self.view.addConstraint(scrollViewBottomToSuperviewBottomConstraint)
    UIView.animate(withDuration: 0.44) {
      self.view.layoutIfNeeded()
    }
  }

  func keyboardWillHide(_ notification: NSNotification) {
    self.view.removeConstraint(scrollViewBottomToSuperviewBottomConstraint)
    self.view.addConstraint(scrollViewBottomToLabelTopConstraint)
    UIView.animate(withDuration: 0.44) {
      self.view.layoutIfNeeded()
    }
  }
}

extension RegisterViewController: InformativeInputFieldDelegate {
  func informativeInputFieldDidTapField(informativeInputField: InformativeInputField) {
    let countryPickerViewController: EMCCountryPickerController = EMCCountryPickerController()
    countryPickerViewController.labelFont = FontDynamicType.subheadline.font
    countryPickerViewController.countryDelegate = self
    countryPickerViewController.flagSize = 44
    
    self.navigationController?.pushViewController(countryPickerViewController, animated: true)
  }
}

extension RegisterViewController:  EMCCountryDelegate {
  func countryController(_ sender: Any?, didSelect chosenCountry: EMCCountry?) {
    if let chosenCountry = chosenCountry {
      let countryName: String = chosenCountry.countryName(with: Locale.current)
      let countryCode: String = chosenCountry.countryCode
      viewModel.country = (countryCode, countryName)
      countryField.text = viewModel.country?.name ?? ""
    }
    _ = self.navigationController?.popToViewController(self, animated: true)
  }
}

extension RegisterViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    WebViewController.present(url: url, inViewController: self)
  }
}

extension RegisterViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()
    continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: continueButton)
    stackViewBackgroundView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }
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

enum AttributedLinkReference: String {
 case termsOfUse = "/terms#terms"
 case privacyPolicy = "/terms#privacy"

  var url: URL {
    get {
      return URL(string: "https://www.bookwitty.com" + self.rawValue)!
    }
  }
}
