//
//  RegisterViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

final class RegisterViewModel {
  let viewControllerTitle: String = localizedString(key: "sign_up", defaultValue: "Sign up")

  let continueButtonTitle: String = localizedString(key: "continue", defaultValue: "Continue")

  let okText: String = localizedString(key: "ok", defaultValue: "Ok")

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

  let countryDescriptionLabelText: String = localizedString(key: "country", defaultValue: "Country")
  let countryTextFieldPlaceholderText: String = localizedString(key: "country_text_field_placeholder", defaultValue: "Country")

  let termsOfUseText: String = localizedString(key: "terms_of_use", defaultValue: "Terms of Use")
  let privacyPolicyText: String = localizedString(key: "privacy_policy", defaultValue: "Privacy Policy")
  let andText: String = localizedString(key: "and", defaultValue: "and")
  let termsOfUseAndPrivacyPolicyLabelText: String = localizedString(key: "terms_of_use_and_privacy_policy", defaultValue: "By tapping Sign up, you agree to the")

  let ooopsText: String = localizedString(key: "ooops", defaultValue: "Ooops")
  let somethingWentWrongText: String = localizedString(key: "some_thing_wrong_error", defaultValue: "Something went wrong")
  let registerErrorInFieldsNotification = localizedString(key: "invalid_fields_notification_message", defaultValue: "Please fill the required fields")

  var country: (code: String, name: String)?

  init() {
    self.country = loadDeviceDefaultCountry()
  }

  func loadDeviceDefaultCountry() -> (code: String, name: String)? {
    let countryLocale = Locale.current as NSLocale

    guard let code = countryLocale.object(forKey: .countryCode) as? String else {
      return nil
    }

    if let name = countryLocale.displayName(forKey: .countryCode, value: code) {
      return (code: code, name: name)
    }

    return nil
  }

  func styledTermsOfUseAndPrivacyPolicyText() -> NSMutableAttributedString {
    let builder = AttributedStringBuilder(fontDynamicType: FontDynamicType.label)
    return builder.append(text: termsOfUseAndPrivacyPolicyLabelText)
      .append(text: "\n")
      .append(text: termsOfUseText)
      .append(text:  " " + andText + " ")
      .append(text: privacyPolicyText)
      .applyParagraphStyling(alignment: NSTextAlignment.center)
      .attributedString
  }

  func registerUserWithData(firstName: String, lastName: String, email: String, country: String, password: String, completionBlock: @escaping (_ success: Bool, _ user: User?)->()) {
    _ = apiRequest(target: BookwittyAPI.register(firstName: firstName, lastName: lastName, email: email, dateOfBirthISO8601: nil, countryISO3166: country, password: password)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      defer {
        completionBlock(success, user)
      }

      if let data = data, statusCode == 201 {
        user = User.parseData(data: data)
        success = user != nil
      }
    }
  }
}
