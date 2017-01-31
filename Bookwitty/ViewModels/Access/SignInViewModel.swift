//
//  File.swift
//  Bookwitty
//
//  Created by Marwan  on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class SignInViewModel {
  let signInButtonTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
  let emailDescriptionLabelText: String = localizedString(key: "email", defaultValue: "Email")
  let emailTextFieldPlaceholderText: String = localizedString(key: "email_text_field_placeholder", defaultValue: "Enter your email")
  let emailInvalidationErrorMessage: String = localizedString(key: "email_invalidation_error_message", defaultValue: "Oooops your email seems to be invalid")
  
  let passwordDescriptionLabelText: String = localizedString(key: "password", defaultValue: "Password")
  let passwordTextFieldPlaceholderText: String = localizedString(key: "password_text_field_placeholder", defaultValue: "Enter your password")
  let passwordInvalidationErrorMessage: String = localizedString(key: "password_invalidation_error_message", defaultValue: "Oooops your password seems to be invalid")
  
  let viewControllerTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
}
