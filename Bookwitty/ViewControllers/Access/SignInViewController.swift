//
//  SignInViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SwiftLoader
import FBSDKLoginKit

class SignInViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
  @IBOutlet weak var registerLabel: TTTAttributedLabel!
  @IBOutlet weak var forgotPasswordLabel: TTTAttributedLabel!
  @IBOutlet var separators: [UIView]!
  
  @IBOutlet weak var scrollViewBottomToButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!
  
  let viewModel: SignInViewModel = SignInViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
    applyTheme()

    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    facebookSignInButton.delegate = self
    
    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.SignIn)
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
  
  /// Do the required setup
  private func awakeSelf() {
    emailField.validationBlock = emailValidation()
    passwordField.validationBlock = passwordValidation()

    emailField.delegate = self
    passwordField.delegate = self
    
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(SignInViewController.keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(SignInViewController.keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  fileprivate func setupAttributedTexts() {
    //Set Attributed Styled up Text
    registerLabel.attributedText = viewModel.styledRegisterText()
    //Attributed Label Links Styling
    var attributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()
    attributes.updateValue(FontDynamicType.footnote.font, forKey: NSFontAttributeName)
    registerLabel.linkAttributes = attributes
    
    let registerTermRange: NSRange = (registerLabel.attributedText.string as NSString).range(of: Strings.register())
    
    //Add click link identifiers
    registerLabel.addLink(to: AttributedLinkReference.register.url, with: registerTermRange)
    
    //Set Delegates
    registerLabel.delegate = self

    let forgotPasswordText = viewModel.styledForgotPasswordText()
    let range = NSRange(location: 0, length: forgotPasswordText.length)
    forgotPasswordLabel.attributedText = forgotPasswordText
    forgotPasswordLabel.linkAttributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()
    forgotPasswordLabel.addLink(to: AttributedLinkReference.forgotPassword.url, with: range)

    forgotPasswordLabel.delegate = self
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func emailValidation() -> (String?) -> Bool {
    return { (email: String?) -> Bool in
      return email?.isValidEmail() ?? false
    }
  }
  
  func passwordValidation() -> (String?) -> Bool {
    return { (password: String?) -> Bool in
      return password?.isValidPassword() ?? false
    }
  }
  
  
  @IBAction func signInButtonTouchUpInside(_ sender: Any) {
    let emailValidationResult = emailField.validateField()
    let passwordValidationResult = passwordField.validateField()

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

    showLoader()

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .Account,
                                                 action: .SignIn)
    Analytics.shared.send(event: event)

    viewModel.signIn(
      username: emailValidationResult.value!,
      password: passwordValidationResult.value!,
      completion: { (success, error) in
        self.hideLoader()
        if success {
          NotificationCenter.default.post(name: AppNotification.didSignIn, object: nil)
        } else {
          self.showAlertWith(
            title: Strings.sign_in(),
            message: Strings.something_wrong_in_credentials())
        }
    })
  }
  
  
  // MARK: - Keyboard Handling
  
  func keyboardWillShow(_ notification: NSNotification) {
    // Hide notification view if visible
    NotificationView.hide()
    
    if let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let frame = value.cgRectValue
      scrollViewBottomToSuperviewBottomConstraint.constant = -frame.height
    }
    
    self.view.removeConstraint(scrollViewBottomToButtonTopConstraint)
    self.view.addConstraint(scrollViewBottomToSuperviewBottomConstraint)
    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    self.view.removeConstraint(scrollViewBottomToSuperviewBottomConstraint)
    self.view.addConstraint(scrollViewBottomToButtonTopConstraint)
    UIView.animate(withDuration: 0.44) { 
      self.view.layoutSubviews()
    }
  }
  
  // MARK: - Network indicator handling
  
  private func showLoader() {
    SwiftLoader.show(animated: true)
  }
  
  private func hideLoader() {
    SwiftLoader.hide()
  }
  
  
  // MARK: - Helper methods
  
  fileprivate func pushRegisterViewController() {
    let registerViewController = Storyboard.Access.instantiate(RegisterViewController.self)
    navigationController?.pushViewController(registerViewController, animated: true)
  }
}


// MARK: - Themeable

extension SignInViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    signInButton.setTitle(Strings.sign_in(), for: .normal)
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: signInButton)
    stackViewBackgroundView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    
    for separator in separators {
      separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    }
  }
}

// MARK: - Input fields delegate
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

// MARK: - TTTAttributedText delegate
extension SignInViewController: TTTAttributedLabelDelegate {
  enum AttributedLinkReference: String {
    case register
    
    case forgotPassword
    var url: URL {
      get {
        return URL(string: "bookwittyapp://" + self.rawValue)!
      }
    }
  }
  
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    guard let host = url.host else {
      return
    }
    
    switch host {
    case AttributedLinkReference.register.rawValue:
      registerAction()
    case AttributedLinkReference.forgotPassword.rawValue:
      pushForgotPasswordViewController()
    default:
      break
    }
  }
  
  /**
   If the view controller was presented modally then the sign should be
   notifying the the root vc, otherwise it should be notifying the Introduction vc
  */
  private func registerAction() {
    if let notificationName = viewModel.registerNotificationName {
      NotificationCenter.default.post(name: notificationName, object: nil)
    } else {
      pushRegisterViewController()
    }
  }

  fileprivate func pushForgotPasswordViewController() {
    let forgotPasswordViewController = Storyboard.Account.instantiate(ForgotPasswordViewController.self)
    navigationController?.pushViewController(forgotPasswordViewController, animated: true)
  }
}

//MARK: - Localizable implementation
extension SignInViewController: Localizable {
  func applyLocalization() {
    title = Strings.sign_in()

    setupAttributedTexts()

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
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

//MARK: - Facebook Login Button Delegate
extension SignInViewController: FBSDKLoginButtonDelegate {
  func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
    return false
  }
  
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) { }
  
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) { }
}
