//
//  RegisterViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import CoreTelephony

final class RegisterViewModel {
  var country: (code: String, name: String)?

  init() {
    self.country = loadDeviceDefaultCountry()
  }

  /*
  * Discussion:
  * Locale.current.regionCode provides the Regions selected in the Device's Settings
  * This value might not be accurate
  * For greater Precision, we're getting the country code from the Telephony Carrier
  */
  func loadDeviceDefaultCountry() -> (code: String, name: String)? {
    //The Cellular Service Carrier
    let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider

    guard let code = carrier?.isoCountryCode ?? Locale.current.regionCode else {
      return nil
    }

    if let name = Locale.application.localizedString(forRegionCode: code) {
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

    let language = GeneralSettings.sharedInstance.preferredLanguage
    request = UserAPI.registerUser(firstName: firstName, lastName: lastName, email: email, dateOfBirthISO8601: nil, countryISO3166: country, password: password, language: language, completionBlock: { (success, user, error) in
      guard success, let registeredUser = user else {
        self.request = nil
        completionBlock(success, user, error)
        return
      }
      
      self.request = UserAPI.signIn(withUsername: email, password: password, completion: { (success, error) in
        self.request = nil
        var error = BookwittyAPIError.failToSignIn
        if !success {
          error = BookwittyAPIError.failToSignIn
        }
        completionBlock(success, registeredUser, error)
      })
    })
  }
}
