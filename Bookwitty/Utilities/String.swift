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
    /* Discussion
     * Number of Characters defined by the Register API 
     * fails with 409, pointer password
     */
    let minimumNumberOfCharacters = 8
    return self.characters.count >= minimumNumberOfCharacters
  }

  func isValidText() -> Bool {
    let count: Int = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count
    return !(count == 0)
  }

  static func fromData(data: Data?) -> String? {
   return String(data: data!, encoding: .utf8)
  }
}

extension String {
  /// Returns a newly created string with no spaces or new lines.
  var trimmed: String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// String with no spaces or new lines in beginning and end.
  mutating func trim() {
    self = self.trimmed
  }
}

extension String {
  
  /// String encoded in base64 (if applicable).
  ///
  ///		"Hello World!".base64Encoded -> Optional("SGVsbG8gV29ybGQh")
  ///
  public var base64Encoded: String? {
    // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
    let plainData = data(using: .utf8)
    return plainData?.base64EncodedString()
  }
}

//Adds a failable init that mirrors the Int? given
extension String {
  init?(counting: Int?) {
    guard let count = counting else{
      return nil
    }

    self = String(count)
  }
}

extension String {
  func capitalizeFirstLetter() -> String {
    let first = String(characters.prefix(1)).capitalized
    let other = String(characters.dropFirst())
    return first + other
  }
}

protocol StringType {
  var get: String { get }
}

extension String: StringType {
  var get: String { return self }
}

extension Optional where Wrapped: StringType {
  func isEmptyOrNil() -> Bool {
    guard self != nil else {
      return true
    }
    return self!.get.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

extension String {
  var isBlank: Bool {
    return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}
