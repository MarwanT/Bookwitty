//
//  File.swift
//  Bookwitty
//
//  Created by Marwan  on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class SignInViewModel {
  let signInButtonTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
  let emailDescriptionLabelText: String = localizedString(key: "email", defaultValue: "Email")
  let emailTextFieldPlaceholderText: String = localizedString(key: "email_text_field_placeholder", defaultValue: "Enter your email")
  let emailInvalidationErrorMessage: String = localizedString(key: "email_invalidation_error_message", defaultValue: "Oooops your email seems to be invalid")
  
  let passwordDescriptionLabelText: String = localizedString(key: "password", defaultValue: "Password")
  let passwordTextFieldPlaceholderText: String = localizedString(key: "password_text_field_placeholder", defaultValue: "Enter your password")
  let passwordInvalidationErrorMessage: String = localizedString(key: "password_invalidation_error_message", defaultValue: "Oooops your password seems to be invalid")
  
  let viewControllerTitle: String = localizedString(key: "sign_in", defaultValue: "Sign-in")
  let signInErrorInFieldsNotification = localizedString(key: "invalid_fields_notification_message", defaultValue: "Please fill the required fields")
  let okText: String = localizedString(key: "ok", defaultValue: "Ok")
  let failToSignInAlertTitle: String = localizedString(
    key: "fail_to_sign_alert_title",
    defaultValue: "Sign in")
  let failToSignInAlertMessage: String = localizedString(key: "fail_to_sign_in_alert_message", defaultValue: "Oooops it seems there is something wrong in your credentials")
  let registerLabelText: String = localizedString(key: "sign_in_register_sentence", defaultValue: "You don't have an account")
  let registerTermText: String = localizedString(key: "register", defaultValue: "Register")
  
  
  func styledRegisterText() -> NSMutableAttributedString {
    let builder = AttributedStringBuilder(fontDynamicType: FontDynamicType.label)
    return builder.append(text: registerLabelText)
      .append(text: "\n")
      .append(text: registerTermText)
      .applyParagraphStyling(alignment: NSTextAlignment.center)
      .attributedString
  }
  
  
  private var request: Cancellable? = nil
  
  func signIn(username: String, password: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?)-> Void ) {
    if let request = request {
      request.cancel()
    }
    
    request = UserAPI.signIn(withUsername: username, password: password, completion: {
      (success, error) in
      self.request = nil
      completion(success, error)
    })
  }
  
  var registerNotificationName: Notification.Name? = nil
}
