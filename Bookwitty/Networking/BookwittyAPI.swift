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
  case refreshToken(refreshToken: String)
  case allAddresses
  case register(firstName: String, lastName: String, email: String, dateOfBirthISO8601: String?, countryISO3166: String, password: String, language: String)
  case user
  case updateUser(identifier: String, firstName: String?, lastName: String?, dateOfBirth: String?, email: String?, currentPassword: String?, password: String?, country: String?, badges: [String : Any]?, preferences: [String : Any]?)
  case bookStore
  case categoryCuratedContent(categoryIdentifier: String)
  case newsFeed(penNameId: String)
  case Search(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?)
  case updatePenName(identifier: String, name: String?, biography: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?)
  case batch(identifiers: [String])
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
      path = "/user"
    case .user:
      path = "/user"
    case .updateUser:
      path = "/user"
    case .bookStore:
      path = "/curated_collection/book_storefront"
    case .categoryCuratedContent(let categoryIdentifier):
      path = "/curated_collection/category/\(categoryIdentifier)"
    case .newsFeed(let penNameIdentifier):
      path = "/pen_names/\(penNameIdentifier)/feed"
    case .Search:
      path = "/search"
    case .updatePenName(let identifier, _, _, _, _, _, _, _, _, _, _, _, _, _):
      path = "/pen_names/\(identifier)"
    case .batch:
      path = "/content/batch"
    }
    
    return apiBasePath + apiVersion + path
  }
  
  public var method: Moya.Method {
    switch self {
    case .oAuth, .refreshToken:
      return .post
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .Search:
      return .get
    case .register, .batch:
      return .post
    case .updateUser, .updatePenName:
      return .patch
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
    case .refreshToken(let refreshToken):
      return [
        "client_id": AppKeys.shared.apiKey,
        "client_secret": AppKeys.shared.apiSecret,
        "refresh_token": refreshToken,
        "grant_type": "refresh_token",
        "scopes": "openid email profile"
      ]
    case .batch(let identifiers):
      return [
        "ids" : identifiers
      ]
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed:
      return nil
    case .register(let firstName, let lastName, let email, let dateOfBirth, let country, let password, let language):
      return UserAPI.registerPostBody(firstName: firstName, lastName: lastName, email: email, dateOfBirth: dateOfBirth, country: country, password: password, language: language)

    case .updateUser(let identifier, let firstName, let lastName, let dateOfBirth, let email, let currentPassword, let password, let country, let badges, let preferences):
      return UserAPI.updatePostBody(identifier: identifier, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, email: email, currentPassword: currentPassword, password: password, country: country, badges: badges, preferences: preferences)
    case .Search(let filter, let page):
      var dictionary = [String : Any]()

      //Filters
      if let filter = filter {
        if let query = filter.query {
          dictionary["filter[query]"] = query
        }

        if let category = filter.category {
          dictionary["filter[category]"] = category
        }
      }

      //Pagination
      if let page = page {
        if let number = page.number {
          dictionary["page[number]"] = number
        }

        if let size = page.size {
          dictionary["page[size]"] = size
        }
      }

      return dictionary
    case .updatePenName(let identifier, let name, let biography, let avatarUrl, let facebookUrl, let tumblrUrl, let googlePlusUrl, let twitterUrl, let instagramUrl, let pinterestUrl, let youtubeUrl, let linkedinUrl, let wordpressUrl, let websiteUrl):
      return PenNameAPI.updatePostBody(identifier: identifier, name: name, biography: biography, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl)
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
