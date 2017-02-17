//
//  SignInViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignInViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var registerLabel: TTTAttributedLabel!
  @IBOutlet var separators: [UIView]!
  
  @IBOutlet weak var scrollViewBottomToButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!
  
  let viewModel: SignInViewModel = SignInViewModel()
  
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
  
  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.signInButtonTitle

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

    emailField.validationBlock = emailValidation()
    passwordField.validationBlock = passwordValidation()

    emailField.delegate = self
    passwordField.delegate = self
    
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    setupAttributedTexts()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(SignInViewController.keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(SignInViewController.keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  private func setupAttributedTexts() {
    //Set Attributed Styled up Text
    registerLabel.attributedText = viewModel.styledRegisterText()
    //Attributed Label Links Styling
    registerLabel.linkAttributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()
    
    let registerTermRange: NSRange = (registerLabel.attributedText.string as NSString).range(of: viewModel.registerTermText)
    
    //Add click link identifiers
    registerLabel.addLink(to: AttributedLinkReference.register.url, with: registerTermRange)
    
    //Set Delegates
    registerLabel.delegate = self
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func emailValidation() -> (String?) -> Bool {
    return { (email: String?) -> Bool in
      email?.isValidEmail() ?? false
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
    
    if emailValidationResult.isValid && passwordValidationResult.isValid {
      showNetworkActivity()
      viewModel.signIn(
        username: emailValidationResult.value!,
        password: passwordValidationResult.value!,
        completion: { (success, error) in
          self.hideNetworkActivity()
          if success {
            NotificationCenter.default.post(name: AppNotification.Name.didSignIn, object: nil)
          } else {
            self.showAlertWith(
              title: self.viewModel.failToSignInAlertTitle,
              message: self.viewModel.failToSignInAlertMessage)
          }
      })
    } else {
      NotificationView.show(notificationMessages:
        [
          NotificationMessage(text: viewModel.signInErrorInFieldsNotification)
        ]
      )
    }
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
      self.view.layoutIfNeeded()
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    self.view.removeConstraint(scrollViewBottomToSuperviewBottomConstraint)
    self.view.addConstraint(scrollViewBottomToButtonTopConstraint)
    UIView.animate(withDuration: 0.44) { 
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Network indicator handling
  
  private func showNetworkActivity() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  private func hideNetworkActivity() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  
  // MARK: - Helper methods
  
  func showAlertWith(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: viewModel.okText, style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}


// MARK: - Themeable

extension SignInViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()
    signInButton.setTitle(viewModel.signInButtonTitle, for: .normal)
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
    default:
      break
    }
  }
  
  /**
   If the view controller was presented modally then the sign should be
   notifying the the root vc, otherwise it should be notifying the Introduction vc
  */
  private func registerAction() {
    guard let notificationName = viewModel.registerNotificationName else {
      return
    }
    
    NotificationCenter.default.post(name: notificationName, object: nil)
  }
}
