//
//  String.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension String {
  var urlEscaped: String {
    return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
  }
  
  func isValidEmail() -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return predicate.evaluate(with: self)
  }

  func isValidPassword() -> Bool {
    let minimumNumberOfCharacters = 6
    return self.characters.count > minimumNumberOfCharacters
  }

  func isValidText() -> Bool {
    let count: Int = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count
    return !(count == 0)
  }

  static func fromData(data: Data?) -> String? {
   return String(data: data!, encoding: .utf8)
  }
}
