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
  let viewControllerTitle: String = Strings.sign_up()

  let continueButtonTitle: String = Strings.continue()

  let okText: String = Strings.ok()

  let emailDescriptionLabelText: String = Strings.email()
  let emailTextFieldPlaceholderText: String = Strings.enter_your_email()
  let emailInvalidationErrorMessage: String = Strings.email_invalid()

  let passwordDescriptionLabelText: String = Strings.password()
  let passwordTextFieldPlaceholderText: String = Strings.enter_your_password()
  let passwordInvalidationErrorMessage: String = Strings.password_invalid()

  let firstNameDescriptionLabelText: String = Strings.first_name()
  let firstNameTextFieldPlaceholderText: String = Strings.enter_your_first_name()
  let firstNameInvalidationErrorMessage: String = Strings.first_name_invalid()

  let lastNameDescriptionLabelText: String = Strings.last_name()
  let lastNameTextFieldPlaceholderText: String = Strings.enter_your_last_name()
  let lastNameInvalidationErrorMessage: String = Strings.last_name_invalid()

  let countryDescriptionLabelText: String = Strings.country()
  let countryTextFieldPlaceholderText: String = Strings.country()

  let termsOfUseAndPolicyText: String = Strings.terms_of_use_and_privacy_policy()

  let ooopsText: String = Strings.ooops()
  let somethingWentWrongText: String = Strings.some_thing_wrong_error()
  let emailAlreadyExistsErrorText: String = Strings.email_already_registered()
  let registerErrorInFieldsNotification = Strings.please_fill_required_field()

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
