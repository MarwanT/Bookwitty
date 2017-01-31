//
//  RegisterViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewBackgroundView: UIView!
  @IBOutlet weak var firstNameField: InputField!
  @IBOutlet weak var lastNameField: InputField!
  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var passwordField: PasswordInputField!
  @IBOutlet weak var countryField: InformativeInputField!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var termsLabel: UILabel!
  @IBOutlet var separators: [UIView]!

  let viewModel: RegisterViewModel = RegisterViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
  }

  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.viewControllerTitle
  }
}
