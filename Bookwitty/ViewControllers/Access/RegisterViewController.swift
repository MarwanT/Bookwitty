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
import SwiftLoader

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

    applyLocalization()
    
    awakeSelf()
    applyTheme()

    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.Register)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    navigationController?.navigationBar.backItem?.title = ""

    if case Optional.some = viewModel.userInfo.facebookUserIdentifier {
      //TODO: Localize
      NotificationView.show(notificationMessages: [NotificationMessage(text: "required e-mail, your facebook account will be automatically connected once you complete your registration")])
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.view.endEditing(true)
  }

  fileprivate func setupAttributedTexts() {
    //Set Attributed Styled up Text
    let termsText = viewModel.styledTermsOfUseAndPrivacyPolicyText()
    let termsNSString = termsText.mutableString as NSMutableString

    //Attributed Label Links Styling
    var attributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()
    attributes.updateValue(FontDynamicType.footnote.font, forKey: NSFontAttributeName)
    termsLabel.linkAttributes = attributes

    let range: NSRange = NSRange(location: 0, length: termsNSString.length)
    let regular = try! NSRegularExpression(pattern: "•(.*?)•", options: [])

    var resultRanges: [NSRange] = []
    regular.enumerateMatches(in: termsText.string, options: [], range: range, using: {
      (result: NSTextCheckingResult?, flags, stop) in
      if let result = result {
        resultRanges.append(result.rangeAt(1))
      }
    })

    termsNSString.replaceOccurrences(of: "•", with: "", options: [], range: range)
    termsLabel.attributedText = termsText

    for (index, range) in resultRanges.enumerated() {
      let effectiveRange = NSRange(location: (range.location - (2 * index + 1)), length: range.length)
      switch index {
      case 0:
        termsLabel.addLink(to: AttributedLinkReference.termsOfUse.url, with: effectiveRange)
      case 1:
        termsLabel.addLink(to: AttributedLinkReference.privacyPolicy.url, with: effectiveRange)
      default:
        break
      }
    }

    //Set Delegates
    termsLabel.delegate = self
  }

  /// Do the required setup
  private func awakeSelf() {
    title = Strings.sign_up()

    setupAttributedTexts()

    firstNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.first_name(),
      textFieldPlaceholder: Strings.enter_your_first_name(),
      invalidationErrorMessage: Strings.first_name_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    lastNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.last_name(),
      textFieldPlaceholder: Strings.enter_your_last_name(),
      invalidationErrorMessage: Strings.last_name_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.email(),
      textFieldPlaceholder: Strings.enter_your_email(),
      invalidationErrorMessage: Strings.email_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      keyboardType: .emailAddress,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.password(),
      textFieldPlaceholder: Strings.enter_your_password(),
      invalidationErrorMessage: Strings.password_minimum_characters_error(),
      returnKeyType: UIReturnKeyType.done)

    countryField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.country(),
      textFieldPlaceholder: Strings.country(),
      returnKeyType: UIReturnKeyType.default)

    countryField.text = viewModel.country?.name ?? ""

    emailField.validationBlock = emailValidation()
    passwordField.validationBlock = passwordValidation()
    firstNameField.validationBlock = notEmptyValidation()
    lastNameField.validationBlock = notEmptyValidation()
    countryField.validationBlock = notEmptyValidation()

    emailField.delegate = self
    passwordField.delegate = self
    firstNameField.delegate = self
    lastNameField.delegate = self

    lastNameField.textField.text = viewModel.userInfo.lastName
    firstNameField.textField.text = viewModel.userInfo.firstName

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

  func prefillUserInfo(firstName: String?, lastName: String?, facebookUserIdentifier: String?) {
    viewModel.userInfo = (firstName, lastName, facebookUserIdentifier)
  }

  @IBAction func continueButtonTouchUpInside(_ sender: Any) {
    let emailValidationResult = emailField.validateField()
    let passwordValidationResult = passwordField.validateField()
    let firstNameValidationResult = firstNameField.validateField()
    let lastNameValidationResult = lastNameField.validateField()
    let countryValidationResult = countryField.validateField()

    //Make sure simple fields are not empty
    guard firstNameValidationResult.isValid, lastNameValidationResult.isValid, countryValidationResult.isValid else {
      NotificationView.show(notificationMessages: [NotificationMessage(text: Strings.please_fill_required_field())])
      return
    }

    //Make sure the e-mail is valid
    guard emailValidationResult.isValid else {
      if let email = emailValidationResult.value, email.characters.count > 0 {
        let error = emailValidationResult.errorMessage ?? Strings.please_fill_required_field()
        NotificationView.show(notificationMessages: [NotificationMessage(text: error)])
      } else {
        NotificationView.show(notificationMessages: [NotificationMessage(text: Strings.please_fill_required_field())])
      }
      return
    }

    //Make sure the password is valid
    guard passwordValidationResult.isValid else {
      if let password = passwordValidationResult.value, password.characters.count > 0 {
        let error = passwordValidationResult.errorMessage ?? Strings.please_fill_required_field()
        NotificationView.show(notificationMessages: [NotificationMessage(text: error)])
      } else {
        NotificationView.show(notificationMessages: [NotificationMessage(text: Strings.please_fill_required_field())])
      }
      return
    }

    //Make sure we have values
    guard let firstName = firstNameValidationResult.value, let lastName = lastNameValidationResult.value, let country = viewModel.country?.code,
    let email = emailValidationResult.value, let password = passwordValidationResult.value else {
      NotificationView.show(notificationMessages: [NotificationMessage(text: Strings.please_fill_required_field())])
      return
    }

    showLoader()

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .Register)
    Analytics.shared.send(event: event)

    let facebookUserIdentifier = viewModel.userInfo.facebookUserIdentifier
    viewModel.registerUserWithData(firstName: firstName, lastName: lastName, email: email, country: country, password: password, facebookUserIdentifier: facebookUserIdentifier, completionBlock: { (success: Bool, user: User?, error: BookwittyAPIError?) in
      self.hideLoader()
      let successBlock = {
        UserManager.shared.shouldEditPenName = true
        NotificationCenter.default.post(name: AppNotification.registrationSuccess, object: user)
      }
      let failBlock = { (message: String) in
        self.showAlertErrorWith(title: Strings.ooops(), message: message)
      }

      if user != nil, success {
        successBlock()
      } else if let error = error {
        switch(error) {
        case BookwittyAPIError.emailAlreadyExists:
          failBlock(Strings.email_already_registered())
        case .failToSignIn:
          /*
           Registration is successful, but since the sign in failed then
           The root vc will re-display the sign in vc for signing in again
           */
          successBlock()
        default: break
        }
      } else {
        failBlock(Strings.some_thing_wrong_error())
      }
    })
  }

  func showAlertErrorWith(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: Strings.ok(), style: UIAlertActionStyle.default, handler: nil))
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
  
  // MARK: - Network indicator handling
  private func showLoader() {
    SwiftLoader.show(animated: true)
  }
  
  private func hideLoader() {
    SwiftLoader.hide()
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
      self.view.layoutSubviews()
    }
  }

  func keyboardWillHide(_ notification: NSNotification) {
    self.view.removeConstraint(scrollViewBottomToSuperviewBottomConstraint)
    self.view.addConstraint(scrollViewBottomToLabelTopConstraint)
    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
}

extension RegisterViewController: InformativeInputFieldDelegate {
  func informativeInputFieldDidTapField(informativeInputField: InformativeInputField) {
    let countryPickerViewController: EMCCountryPickerController = EMCCountryPickerController()
    countryPickerViewController.labelFont = FontDynamicType.caption2.font
    countryPickerViewController.countryNameDisplayLocale = Locale.application
    countryPickerViewController.countryDelegate = self
    countryPickerViewController.flagSize = 35
    
    self.navigationController?.pushViewController(countryPickerViewController, animated: true)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.CountryList)
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
    SafariWebViewController.present(url: url)

    let name: Analytics.ScreenName
    switch url.relativeString {
    case AttributedLinkReference.termsOfUse.rawValue:
      name = Analytics.ScreenNames.TermsOfUse
    case AttributedLinkReference.privacyPolicy.rawValue:
      name = Analytics.ScreenNames.PrivacyPolicy
    default:
      name = Analytics.ScreenNames.Default
    }

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: name)
  }
}

extension RegisterViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    continueButton.setTitle(Strings.continue(), for: .normal)
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
 case termsOfUse = "/terms?layout=mobile"
 case privacyPolicy = "/privacy?layout=mobile"

  var url: URL {
    get {
      return URL(string: self.rawValue, relativeTo: Environment.current.baseURL)!
    }
  }
}


//MARK: - Localizable implementation
extension RegisterViewController: Localizable {
  func applyLocalization() {
    title = Strings.sign_up()

    setupAttributedTexts()

    firstNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.first_name(),
      textFieldPlaceholder: Strings.enter_your_first_name(),
      invalidationErrorMessage: Strings.first_name_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    lastNameField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.last_name(),
      textFieldPlaceholder: Strings.enter_your_last_name(),
      invalidationErrorMessage: Strings.last_name_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      autocorrectionType: .no)

    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.email(),
      textFieldPlaceholder: Strings.enter_your_email(),
      invalidationErrorMessage: Strings.email_invalid(),
      returnKeyType: UIReturnKeyType.continue,
      keyboardType: .emailAddress,
      autocorrectionType: .no,
      autocapitalizationType: .none)

    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.password(),
      textFieldPlaceholder: Strings.enter_your_password(),
      invalidationErrorMessage: Strings.password_minimum_characters_error(),
      returnKeyType: UIReturnKeyType.done)

    countryField.configuration = InputFieldConfiguration(
      descriptionLabelText: Strings.country(),
      textFieldPlaceholder: Strings.country(),
      returnKeyType: UIReturnKeyType.default)
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
