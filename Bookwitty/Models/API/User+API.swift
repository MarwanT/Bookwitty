//
//  User+API.swift
//  Bookwitty
//
//  Created by Marwan  on 2/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

struct UserAPI {
  enum AuthPlatfrom {
    case bookwitty(username: String, password: String)
    case google(token: String)
  }

  public static func signIn(with platform: AuthPlatfrom, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let target: BookwittyAPI

    switch platform {
    case .bookwitty(let username, let password):
      target = BookwittyAPI.oAuth(credentials: (username: username, password: password))
    case .google(let token):
      target = BookwittyAPI.googleSignIn(token: token)
    }

    return apiRequest(
    target: target) {
      (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      defer {
        completion(success, error)
      }
      
      // If status code is not available then break
      guard let statusCode = statusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }
      
      // If status code != success then break
      if statusCode != 200 {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }
      
      // Retrieve Dictionary from data
      do {
        guard let data = data, let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
          return
        }
        // Save token
        AccessToken.shared.save(dictionary: dictionary)
        success = true
        completionError = nil
      } catch {
        completionError = BookwittyAPIError.failToRetrieveDictionary
      }
    }
  }

  public static func signInAonymously(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return apiRequest(
    target: BookwittyAPI.oAuth(credentials: nil)) {
      (data, statusCode, response, error) in
      // Ensure the completion block is always called
      var success: Bool = false
      var completionError: BookwittyAPIError? = error
      defer {
        completion(success, error)
      }

      // If status code is not available then break
      guard let statusCode = statusCode else {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // If status code != success then break
      if statusCode != 200 {
        completionError = BookwittyAPIError.invalidStatusCode
        return
      }

      // Retrieve Dictionary from data
      do {
        guard let data = data, let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
          return
        }
        // Save token
        AccessToken.shared.save(dictionary: dictionary)
        success = true
        completionError = nil
      } catch {
        completionError = BookwittyAPIError.failToRetrieveDictionary
      }
    }
  }

  public static func registerUser(firstName: String, lastName: String, email: String, dateOfBirthISO8601: String? = nil, countryISO3166: String, password: String, language: String, facebookUserIdentifier: String? = nil, completionBlock: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?)->()) -> Cancellable? {

    let successStatusCode = 201
    let emailAlreadyUsedStatusCode = 409

    return signedAPIRequest(target: BookwittyAPI.register(firstName: firstName, lastName: lastName, email: email, dateOfBirthISO8601: dateOfBirthISO8601, countryISO3166: countryISO3166, password: password, language: language, facebookUserIdentifier: facebookUserIdentifier)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, user, error)
      }

      if statusCode == emailAlreadyUsedStatusCode {
        error = BookwittyAPIError.emailAlreadyExists
        return
      }

      // If status code != success then break
      if statusCode != successStatusCode {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      if let data = data {
        user = User.parseData(data: data)
        success = user != nil

        if let user = user {
          UserManager.shared.signedInUser = user
        }

      } else {
        error = BookwittyAPIError.failToParseData
      }
    }
  }
  
  public static func user(completion: @escaping (_ success: Bool, _ user: User?, _ oneTimeToken: String?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    
    let successStatusCode = 200
    
    return signedAPIRequest(target: .user, completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      var oneTimeToken: String? = nil
      var error: BookwittyAPIError? = error
      defer {
        completion(success, user, oneTimeToken, error)
      }
      
      // If status code != success then break
      if statusCode != successStatusCode {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
      
      if let data = data {
        user = User.parseData(data: data)
        success = user != nil
        oneTimeToken = user?.oneTimeToken

        if let user = user {
          UserManager.shared.signedInUser = user
        }

      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func updateUser(identifier: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, currentPassword: String? = nil, password: String? = nil, dateOfBirthISO8601: String? = nil, countryISO3166: String? = nil, completeOnboarding: Bool? = nil, badges: [String : Any]? = nil, preferences: [String : Any]? = nil, completionBlock: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?)->()) -> Cancellable? {

    let successStatusCode = 200
    let errorStatusCode = 422
    /** Discussion
     * Status Code 422 represents multiple errors in the updateUser endpoint.
     * Changing Password allows the detection of this particular error. 
     * Returned as BookwittyAPIError.invalidCurrentPassword
     */
    let changingPassword = (!currentPassword.isEmptyOrNil() || !password.isEmptyOrNil())

    return signedAPIRequest(target: BookwittyAPI.updateUser(identifier: identifier, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirthISO8601, email: email, currentPassword: currentPassword, password: password, country: countryISO3166, completeOnboarding: completeOnboarding, badges: badges, preferences: preferences), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, user, error)
      }

      guard statusCode == successStatusCode else {
        if statusCode == errorStatusCode && changingPassword {
          error = BookwittyAPIError.invalidCurrentPassword
        } else {
          error = BookwittyAPIError.undefined
        }
        return
      }

      if let data = data {
        user = User.parseData(data: data)
        success = user != nil

        if let user = user {
          user.penNames = UserManager.shared.signedInUser.penNames
          UserManager.shared.signedInUser = user
        }

      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }
  
  public static func batch(identifiers: [String], completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    
    let successStatusCode = 200
    
    return signedAPIRequest(target: .batch(identifiers: identifiers), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var resources: [Resource]? = nil
      var error: BookwittyAPIError? = error
      DispatchQueue.global(qos: .background).async {
        defer {
          DispatchQueue.main.async {
            completion(success, resources, error)
          }
        }

        guard statusCode == successStatusCode else {
          error = BookwittyAPIError.invalidStatusCode
          return
        }

        if let data = data {
          // Parse Data
          guard let parsedData = Parser.parseDataArray(data: data) else {
            error = BookwittyAPIError.failToParseData
            return
          }
          resources = parsedData.resources
          success = resources != nil
          //TODO: handle parsedData.next and parsedData.errors if any
        } else {
          error = BookwittyAPIError.failToParseData
        }
      }
    })
  }

  static func updateUser(preference: User.Preference, value: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {

    let successStatusCode = 204

    return signedAPIRequest(target: .updatePreference(preference: preference.rawValue, value: value), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, error)
      }

      success = statusCode == successStatusCode
    })
  }

  static func resetPassword(email: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode = 204

    return signedAPIRequest(target: .resetPassword(email: email)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var error: BookwittyAPIError? = error
      defer {
        completion(success, error)
      }

      // If status code != success then break
      if statusCode != successStatusCode {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      success = true
    }
  }
}

//MARK: - Moya Needed parameters
extension UserAPI {
  static func registerPostBody(firstName: String?, lastName: String?, email: String?, dateOfBirth: String?, country: String?, password: String?, language: String?, facebookUserIdentifier: String?) -> [String : Any]? {
    //Create Body
    let user = User()
    user.firstName = firstName
    user.lastName = lastName
    user.email = email
    user.dateOfBirth = dateOfBirth
    user.country = country
    user.password = password
    user.language = language
    //Serialize Body to conform to JSONAPI
    return user.serializeData(options: [.OmitNullValues])
  }

  static func updatePostBody(identifier: String, firstName: String?, lastName: String?, dateOfBirth: String?, email: String?, currentPassword: String?, password: String?, country: String?, completeOnboarding: Bool?, badges: [String : Any]?, preferences: [String : Any]?) -> [String : Any]? {
    let user = User()
    user.id = identifier
    user.firstName = firstName
    user.lastName = lastName
    user.dateOfBirth = dateOfBirth
    user.email = email
    user.country = country
    user.currentPassword = currentPassword
    user.password = password
    user.badges = badges
    user.preferences = preferences
    if let completeOnboarding = completeOnboarding {
      user.onboardComplete = NSNumber(value: completeOnboarding)
    }
    return user.serializeData(options: [.IncludeID, .OmitNullValues])
  }
  
  static func batchPostBody(identifiers: [String]) -> [String : Any]? {
    let dictionary = [
      "data" : [
        "attributes" : [
          "ids" : identifiers,
        ]
      ]
    ]
    return dictionary
  }

  static func updatePostBody(preference: String, value: String) -> [String : Any]? {
    let dictionary = [
      "data" : [
        "type": "users",
        "attributes" : [
          "preference" : preference,
          "value" : value
        ]
      ]
    ]
    return dictionary
  }

  static func resetPasswordBody(email: String) -> [String : Any]? {
    let dictionary = [
      "data" : [
        "attributes" : [
          "email" : email
        ]
      ]
    ]
    return dictionary
  }
}
