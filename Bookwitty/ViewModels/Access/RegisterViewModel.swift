//
//  RegisterViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class RegisterViewModel {
  let viewControllerTitle: String = localizedString(key: "sign_up", defaultValue: "Sign up")

  let emailDescriptionLabelText: String = localizedString(key: "email", defaultValue: "Email")
  let emailTextFieldPlaceholderText: String = localizedString(key: "email_text_field_placeholder", defaultValue: "Enter your email")
  let emailInvalidationErrorMessage: String = localizedString(key: "email_invalidation_error_message", defaultValue: "Oooops your email seems to be invalid")

  let passwordDescriptionLabelText: String = localizedString(key: "password", defaultValue: "Password")
  let passwordTextFieldPlaceholderText: String = localizedString(key: "password_text_field_placeholder", defaultValue: "Enter your password")
  let passwordInvalidationErrorMessage: String = localizedString(key: "password_invalidation_error_message", defaultValue: "Oooops your password seems to be invalid")

  let firstNameDescriptionLabelText: String = localizedString(key: "first_name", defaultValue: "First name")
  let firstNameTextFieldPlaceholderText: String = localizedString(key: "first_name_text_field_placeholder", defaultValue: "Enter your first name")
  let firstNameInvalidationErrorMessage: String = localizedString(key: "first_name_invalidation_error_message", defaultValue: "Oooops your first name seems to be empty")

  let lastNameDescriptionLabelText: String = localizedString(key: "last_name", defaultValue: "Last name")
  let lastNameTextFieldPlaceholderText: String = localizedString(key: "last_name_text_field_placeholder", defaultValue: "Enter your last name")
  let lastNameInvalidationErrorMessage: String = localizedString(key: "last_name_invalidation_error_message", defaultValue: "Oooops your email seems to be empty")

  let countryTextFieldPlaceholderText: String = localizedString(key: "country", defaultValue: "Country")
}
