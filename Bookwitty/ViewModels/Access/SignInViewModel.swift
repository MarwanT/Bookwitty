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
    let builder = AttributedStringBuilder(fontDynamicType: FontDynamicType.label)
    return builder.append(text: Strings.you_dont_have_account())
      .append(text: "\n")
      .append(text: Strings.register())
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
