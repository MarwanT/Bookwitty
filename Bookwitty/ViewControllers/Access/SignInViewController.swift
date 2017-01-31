//
//  SignInViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var informationLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
  }
  
  /// Do the required setup
  private func awakeSelf() {
    emailField.configuration = InputFieldConfiguration(
      descriptionLabelText: "Email", textFieldPlaceholder: "Enter your email",
      invalidationErrorMessage: "Oooops your email seems to be invalid",
      returnKeyType: UIReturnKeyType.continue)
    passwordField.configuration = InputFieldConfiguration(
      descriptionLabelText: "Password", textFieldPlaceholder: "Enter your password",
      invalidationErrorMessage: "Oooops your password seems to be invalid",
      returnKeyType: UIReturnKeyType.done)
  }
}
