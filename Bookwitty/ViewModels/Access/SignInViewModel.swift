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
  let signInButtonTitle: String = Strings.sign_in()
  let emailDescriptionLabelText: String = Strings.email()
  let emailTextFieldPlaceholderText: String = Strings.enter_your_email()
  let emailInvalidationErrorMessage: String = Strings.email_invalid()
  
  let passwordDescriptionLabelText: String = Strings.password()
  let passwordTextFieldPlaceholderText: String = Strings.enter_your_password()
  let passwordInvalidationErrorMessage: String = Strings.password_invalid()
  
  let viewControllerTitle: String = Strings.sign_in()
  let signInErrorInFieldsNotification = Strings.please_fill_required_field()
  let okText: String = Strings.ok()
  let failToSignInAlertTitle: String = Strings.sign_in()
  let failToSignInAlertMessage: String = Strings.something_wrong_in_credentials()
  let registerLabelText: String = Strings.you_dont_have_account()
  let registerTermText: String = Strings.register()
  
  
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
      guard success else {
        self.request = nil
        completion(success, error)
        return
      }
      
      self.request = UserAPI.user(completion: { (success, user, error) in
        var success = success
        var error = error
        defer {
          self.request = nil
          completion(success, error)
        }
        
        guard user != nil, success else {
          success = false
          return
        }

        success = true
      })
    })
  }
  
  var registerNotificationName: Notification.Name? = nil
}
