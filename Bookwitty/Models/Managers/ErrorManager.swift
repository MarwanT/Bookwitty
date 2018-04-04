//
//  ErrorManager.swift
//  Bookwitty
//
//  Created by Marwan  on 3/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class ErrorManager {
  static let shared = ErrorManager()
  private init() {}
  
  func dataContainsAccountNeedsConfirmationError(data: Data) -> (hasError: Bool, error: AppError?) {
    guard let errors = AppError.appErrors(for: data), errors.count > 0 else {
      return (false, nil)
    }
    
    for error in errors {
      if let reasonMeta = error.meta?["reason"] as? String, reasonMeta == "account-unconfirmed" {
        return (true, error)
      }
    }
    
    return (false, nil)
  }
  
  func maxTagsAllowed(data: Data) -> (hasError: Bool, error: AppError?) {
    guard let errors = AppError.appErrors(for: data), errors.count > 0 else {
      return (false, nil)
    }
    
    for error in errors {
      if let code = error.code, code == "tag_count_exceeded" {
        return (true, error)
      }
    }
    
    return (false, nil)
  }
}
