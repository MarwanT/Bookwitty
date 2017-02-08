//
//  BookwittyAPI.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya


// MARK: - Enum Declaration

public enum BookwittyAPI {
  case oAuth(username: String, password: String)
  case refreshToken
  case allAddresses
  case register(firstName: String, lastName: String, email: String, dateOfBirthISO8601: String?, countryISO3166: String, password: String)
  case user
}

// MARK: - Target Type

extension TargetType {
  var headerParameters: [String:String]? {
    return nil
  }
}

extension BookwittyAPI: TargetType {
  public var baseURL: URL {
    return Environment.current.baseURL
  }
  
  public var path: String {
    var apiBasePath = "/api"
    var apiVersion = "/v1"
    var path = ""
    
    switch self {
    case .oAuth, .refreshToken:
      apiBasePath = ""
      apiVersion = ""
      path = "/oauth/token"
    case .allAddresses:
      path = "/user/addresses"
    case .register:
      path = "/users"
    case .user:
      path = "/user"
    }
    
    return apiBasePath + apiVersion + path
  }
  
  public var method: Moya.Method {
    switch self {
    case .oAuth, .refreshToken:
      return .post
    case .allAddresses, .user:
      return .get
    case .register:
      return .post
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .oAuth(let username, let password):
      return [
        "client_id": AppKeys.shared.apiKey,
        "client_secret": AppKeys.shared.apiSecret,
        "username": username,
        "password":  password,
        "grant_type": "password",
        "scopes": "openid email profile"
      ]
    case .refreshToken:
      return [
        "client_id": AppKeys.shared.apiKey,
        "client_secret": AppKeys.shared.apiSecret,
        "refresh_token": AccessToken.shared.refreshToken!,
        "grant_type": "refresh_token",
        "scopes": "openid email profile"
      ]
    case .allAddresses, .user:
      return nil
    case .register(let firstName, let lastName, let email, let dateOfBirth, let country, let password):
      var params: [String : String] = [:]

      params["first-name"] = firstName
      params["last-name"] = lastName
      params["email"] = email
      params["country"] = country
      params["password"] = password
      if let dateOfBirth = dateOfBirth {
        params["date-of-birth"] = dateOfBirth
      }

      return params
    }
  }
  
  public var parameterEncoding: ParameterEncoding {
    switch self.method {
    case .get:
      return URLEncoding.default
    default:
      return JSONEncoding.default
    }
  }
  
  public var sampleData: Data {
    return stubbedResponse(target: self)
  }
  
  /// The type of HTTP task to be performed.
  public var task: Task {
    switch self {
    default:
      return .request
    }
  }
  
  /// Whether or not to perform Alamofire validation. Defaults to `false`.
  public var validate: Bool {
    return false
  }
  
  public var headerParameters: [String:String]? {
    switch (Environment.current.type, self.method) {
    case (.mockServer, .get):
      return ["Prefer": "status=200"]
    case (.mockServer, .post):
      return ["Prefer": "status=201"]
    default:
      return nil
    }
  }

}

// MARK: - Global Helpers

func stubbedResponse(target: BookwittyAPI) -> Data! {
  var filename: String = ""
  
  switch target {
  default:
    filename = ""
  }
  
  let bundle = Bundle.main
  let path = "\(bundle.resourcePath!)/\(filename).json"
  return (try? Data(contentsOf: URL(fileURLWithPath: path)))
}
