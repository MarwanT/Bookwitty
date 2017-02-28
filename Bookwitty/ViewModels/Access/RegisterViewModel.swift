//
//  RegisterViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class RegisterViewModel {
  let viewControllerTitle: String = localizedString(key: "sign_up", defaultValue: "Sign up")

  let continueButtonTitle: String = localizedString(key: "continue", defaultValue: "Continue")

  let okText: String = localizedString(key: "ok", defaultValue: "Ok")

  let emailDescriptionLabelText: String = localizedString(key: "email", defaultValue: "Email")
  let emailTextFieldPlaceholderText: String = localizedString(key: "enter_your_email", defaultValue: "Enter your email")
  let emailInvalidationErrorMessage: String = localizedString(key: "email_invalid", defaultValue: "Oooops your email seems to be invalid")

  let passwordDescriptionLabelText: String = localizedString(key: "password", defaultValue: "Password")
  let passwordTextFieldPlaceholderText: String = localizedString(key: "enter_your_password", defaultValue: "Enter your password")
  let passwordInvalidationErrorMessage: String = localizedString(key: "password_invalid", defaultValue: "Oooops your password seems to be invalid")

  let firstNameDescriptionLabelText: String = localizedString(key: "first_name", defaultValue: "First name")
  let firstNameTextFieldPlaceholderText: String = localizedString(key: "enter_your_first_name", defaultValue: "Enter your first name")
  let firstNameInvalidationErrorMessage: String = localizedString(key: "first_name_invalid", defaultValue: "Oooops your first name seems to be empty")

  let lastNameDescriptionLabelText: String = localizedString(key: "last_name", defaultValue: "Last name")
  let lastNameTextFieldPlaceholderText: String = localizedString(key: "enter_your_last_name", defaultValue: "Enter your last name")
  let lastNameInvalidationErrorMessage: String = localizedString(key: "last_name_invalid", defaultValue: "Oooops your email seems to be empty")

  let countryDescriptionLabelText: String = localizedString(key: "country", defaultValue: "Country")
  let countryTextFieldPlaceholderText: String = localizedString(key: "country", defaultValue: "Country")

  let termsOfUseAndPolicyText: String = localizedString(key: "terms_of_use_and_privacy_policy", defaultValue: "By tapping Sign up : you agree to the\n•Terms of Use• and •Privacy Policy•")

  let ooopsText: String = localizedString(key: "ooops", defaultValue: "Ooops")
  let somethingWentWrongText: String = localizedString(key: "some_thing_wrong_error", defaultValue: "Something went wrong")
  let emailAlreadyExistsErrorText: String = localizedString(key: "email_already_registered", defaultValue: "The email address you have entered is already registered!")
  let registerErrorInFieldsNotification = localizedString(key: "please_fill_required_field", defaultValue: "Please fill the required fields")

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
    return builder.append(text: termsOfUseAndPolicyText)
      .applyParagraphStyling(alignment: NSTextAlignment.center)
      .attributedString
  }

  private var request: Cancellable? = nil

  func registerUserWithData(firstName: String, lastName: String, email: String, country: String, password: String, completionBlock: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?)->()) {
    if let request = self.request {
      request.cancel()
    }

    request = UserAPI.registerUser(firstName: firstName, lastName: lastName, email: email, dateOfBirthISO8601: nil, countryISO3166: country, password: password, language: "en", completionBlock: { (success, user, error) in
      guard success, let registeredUser = user else {
        self.request = nil
        completionBlock(success, user, error)
        return
      }
      
      self.request = UserAPI.signIn(withUsername: email, password: password, completion: { (success, error) in
        self.request = nil
        completionBlock(success, user, error)
      })
    })
  }
}
