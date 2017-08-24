//
//  AuthPlatforms+Constants.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/21.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

enum AuthPlatforms: String {
  case bookwitty = "bookwitty"
  case facebook = "facebook"

  static let genericError: NSError = NSError(domain: AuthErrorConstants.domain, code: AuthErrorConstants.genericErrorCode, userInfo: nil)

  struct AuthErrorConstants {
    private init() {}
    static let domain: String = "AuthPlatforms"
    static let genericErrorCode: Int = 1
    static let facebookMissingEmailErrorCode: Int = 2
  }

  struct UserInfoKeys {
    static let userIdentifier: String = "userIdentifier"
    static let message: String = "message"
    static let name: String = "name"
    static let provider: String = "provider"
  }

  fileprivate struct FacebookErrorMessages {
    static let emailNotProvided: String = "Email Not Provided."
  }

  enum AuthResult {
    case success(NSDictionary)
    case error(NSError)
  }

  static func parse(dictionary: NSDictionary) -> AuthResult {
    guard let keys = dictionary.allKeys as? [String] else {
      return .error(genericError)
    }

    if keys.contains("access_token") {
      return .success(dictionary)
    }

    guard keys.contains("errors"),
      let errorDictionary = (dictionary["errors"] as? [NSDictionary])?.first else {
        return .error(genericError)
    }

    let attributes = errorDictionary["attributes"] as? NSDictionary
    let message = errorDictionary["message"] as? String ?? ""
    let fullName = (attributes?["info"] as? [String : String])?["name"] ?? ""
    let userIdentifier = attributes?["uid"] as? String ?? ""
    let provider = attributes?["provider"] as? String ?? ""
    let authPlatform = AuthPlatforms(rawValue: provider) ?? .bookwitty

    let code: Int
    switch authPlatform {
    case .facebook:
      if message == FacebookErrorMessages.emailNotProvided {
        code = AuthErrorConstants.facebookMissingEmailErrorCode
      } else {
        code = AuthErrorConstants.genericErrorCode
      }
    default:
      code = AuthErrorConstants.genericErrorCode
    }

    let domain: String = AuthErrorConstants.domain
    let userInfo: [String : Any] = [
      UserInfoKeys.userIdentifier : userIdentifier,
      UserInfoKeys.message : message,
      UserInfoKeys.name : fullName,
      UserInfoKeys.provider : authPlatform
    ]

    return .error(NSError(domain: domain, code: code, userInfo: userInfo))
  }
}
