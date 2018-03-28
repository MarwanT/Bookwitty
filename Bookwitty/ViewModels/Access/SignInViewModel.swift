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
  func styledRegisterText() -> NSMutableAttributedString {
    //TODO: Should remove the concatenation
    let builder = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1)
    return builder.append(text: Strings.you_dont_have_account())
      .append(text: "\n")
      .append(text: Strings.register(), fontDynamicType: FontDynamicType.footnote)
      .applyParagraphStyling(alignment: NSTextAlignment.center)
      .attributedString
  }

  func styledForgotPasswordText() -> NSAttributedString {
    let builder = AttributedStringBuilder(fontDynamicType: FontDynamicType.footnote)
    return builder.append(text: Strings.forgot_your_password())
      .applyParagraphStyling(alignment: NSTextAlignment.right)
      .attributedString
  }
  
  
  private var request: Cancellable? = nil
  
  func signIn(username: String, password: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?)-> Void ) {
    if let request = request {
      request.cancel()
    }
    
    request = UserAPI.signIn(with: .bookwitty(username: username, password: password), completion: {
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
