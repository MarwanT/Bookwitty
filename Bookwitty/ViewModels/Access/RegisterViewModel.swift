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
    return builder.append(text: Strings.terms_of_use_and_privacy_policy())
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
