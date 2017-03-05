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
  public static func signIn(withUsername username: String, password: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return apiRequest(
    target: BookwittyAPI.oAuth(username: username, password: password)) {
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


  public static func registerUser(firstName: String, lastName: String, email: String, dateOfBirthISO8601: String? = nil, countryISO3166: String, password: String, language: String, completionBlock: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?)->()) -> Cancellable {

    let successStatusCode = 201
    let emailAlreadyUsedStatusCode = 409

    return apiRequest(target: BookwittyAPI.register(firstName: firstName, lastName: lastName, email: email, dateOfBirthISO8601: dateOfBirthISO8601, countryISO3166: countryISO3166, password: password, language: language)) {
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
  
  public static func user(completion: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    
    let successStatusCode = 200
    
    return signedAPIRequest(target: .user, completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      var error: BookwittyAPIError? = error
      defer {
        completion(success, user, error)
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
    })
  }

  public static func updateUser(identifier: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, currentPassword: String? = nil, password: String? = nil, dateOfBirthISO8601: String? = nil, countryISO3166: String? = nil, badges: [String : Any]? = nil, preferences: [String : Any]? = nil, completionBlock: @escaping (_ success: Bool, _ user: User?, _ error: BookwittyAPIError?)->()) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.updateUser(identifier: identifier, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirthISO8601, email: email, currentPassword: currentPassword, password: password, country: countryISO3166, badges: badges, preferences: preferences), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var user: User? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, user, error)
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
    })
  }
  
  public static func batch(identifiers: [String], completion: @escaping (_ success: Bool, _ resources: [Resource]?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    
    let successStatusCode = 200
    
    return signedAPIRequest(target: .batch(identifiers: identifiers), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var resources: [Resource]? = nil
      var error: BookwittyAPIError? = error
      defer {
        completion(success, resources, error)
      }
      
      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
      
      if let data = data {
        // Parse Data
        guard let parsedData: (resources: [Resource]?, next: URL?, errors: [APIError]?) = Parser.parseDataArray(data: data) else {
          error = BookwittyAPIError.failToParseData
          return
        }
        //TODO: handle parsedData.next and parsedData.errors if any

        resources = parsedData.resources
        success = resources != nil
      } else {
        error = BookwittyAPIError.failToParseData
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
}

//MARK: - Moya Needed parameters
extension UserAPI {
  static func registerPostBody(firstName: String?, lastName: String?, email: String?, dateOfBirth: String?, country: String?, password: String?, language: String?) -> [String : Any]? {
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

  static func updatePostBody(identifier: String, firstName: String?, lastName: String?, dateOfBirth: String?, email: String?, currentPassword: String?, password: String?, country: String?, badges: [String : Any]?, preferences: [String : Any]?) -> [String : Any]? {
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
    return user.serializeData(options: [.IncludeID, .OmitNullValues])
  }
  
  static func batchPostBody(identifiers: [String]) -> [String : Any]? {
    return ["ids" : identifiers]
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
}
