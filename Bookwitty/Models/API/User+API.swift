//
//  User+API.swift
//  Bookwitty
//
//  Created by Marwan  on 2/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya


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
        var accessToken = AccessToken()
        accessToken.readFromDictionary(dictionary: dictionary)
        success = true
        completionError = nil
      } catch {
        completionError = BookwittyAPIError.failToRetrieveDictionary
      }
    }
  }
}

//MARK: - Moya Needed parameters
extension UserAPI {
  static func registerPostBody(firstName: String?, lastName: String?, email: String?, dateOfBirth: String?, country: String?, password: String?) -> [String : Any]? {
    //Create Body
    let user = User()
    user.firstName = firstName
    user.lastName = lastName
    user.email = email
    user.dateOfBirth = dateOfBirth
    user.country = country
    user.password = password
    //Serialize Body to conform to JSONAPI
    return user.serializeData(options: [.OmitNullValues])
  }
}
