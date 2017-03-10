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
    let termsText = viewModel.styledTermsOfUseAndPrivacyPolicyText()
    let termsNSString = termsText.mutableString as NSMutableString

    //Attributed Label Links Styling
    termsLabel.linkAttributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()

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
      invalidationErrorMessage: Strings.password_invalid(),
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
        let successBlock = {
          UserManager.shared.shouldEditPenName = true
          UserManager.shared.shouldDisplayOnboarding = true
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
    } else {
      NotificationView.show(notificationMessages:
        [
          NotificationMessage(text: Strings.please_fill_required_field())
        ]
      )

    }
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
 case termsOfUse = "/terms#terms"
 case privacyPolicy = "/terms#privacy"

  var url: URL {
    get {
      return URL(string: "https://www.bookwitty.com" + self.rawValue)!
    }
  }
}
