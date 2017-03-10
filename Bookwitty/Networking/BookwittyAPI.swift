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
  case newsFeed()
  case Search(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?)
  case updatePenName(identifier: String, name: String?, biography: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?)
  case batch(identifiers: [String])
  case updatePreference(preference: String, value: String)
  case penNames
  case wit(contentId: String)
  case unwit(contentId: String)
  case absolute(url: URL)
  case discover
  case onBoarding
  case follow(identifier: String)
  case unfollow(identifier: String)
  case content(identifier: String, include: [String]?)
  case followers(identifier: String)
  case posts(identifier: String, type: [String]?)
  case editions(identifier: String)
}

// MARK: - Target Type

extension TargetType {
  var headerParameters: [String:String]? {
    return nil
  }

  var includes: [ModelResource.Type]? {
    return nil
  }
}

extension BookwittyAPI: TargetType {
  public var baseURL: URL {
    switch self {
    case .absolute(let fullUrl):
      return fullUrl
    default:
      return Environment.current.baseURL
    }
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
    case .newsFeed:
      path = "/pen_name/feed"
    case .Search:
      path = "/search"
    case .updatePenName(let identifier, _, _, _, _, _, _, _, _, _, _, _, _, _):
      path = "/pen_names/\(identifier)"
    case .batch:
      path = "/content/batch"
    case .updatePreference:
      path = "/user/update_preference"
    case .penNames:
      path = "/user/pen_names"
    case .wit(let contentId):
      path = "/content/\(contentId)/wit"
    case .unwit(let contentId):
      path = "/content/\(contentId)/wit"
    case .discover:
      path = "/curated_collection/discover_page"
    case .onBoarding:
      path = "/curated_collection/onboarding_selection"
    case .absolute(_):
      return ""
    case .follow(let identifier):
      path = "/content/\(identifier)/follow"
    case .unfollow(let identifier):
      path = "/content/\(identifier)/follow"
    case .content(let identifier, _):
      path = "/content/\(identifier)"
    case .followers(let identifier):
      path = "/content/\(identifier)/followers"
    case .posts(let identifier, _):
      path = "/content/\(identifier)/posts"
    case .editions(let identifier):
      path = "/content/\(identifier)/editions"
    }
    
    return apiBasePath + apiVersion + path
  }
  
  public var method: Moya.Method {
    switch self {
    case .oAuth, .refreshToken:
      return .post
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .Search, .penNames, .absolute, .discover, .onBoarding, .content, .followers, .posts, .editions:
      return .get
    case .register, .batch, .updatePreference, .wit, .follow:
      return .post
    case .updateUser, .updatePenName:
      return .patch
    case .unwit, .unfollow:
      return .delete
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
        "grant_type": "refresh_token"
      ]
    case .batch(let identifiers):
      return UserAPI.batchPostBody(identifiers: identifiers)
    case .register(let firstName, let lastName, let email, let dateOfBirth, let country, let password, let language):
      return UserAPI.registerPostBody(firstName: firstName, lastName: lastName, email: email, dateOfBirth: dateOfBirth, country: country, password: password, language: language)
    case .updateUser(let identifier, let firstName, let lastName, let dateOfBirth, let email, let currentPassword, let password, let country, let badges, let preferences):
      return UserAPI.updatePostBody(identifier: identifier, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, email: email, currentPassword: currentPassword, password: password, country: country, badges: badges, preferences: preferences)
    case .Search(let filter, let page):
      return SearchAPI.parameters(filter: filter, page: page)
    case .updatePenName(let identifier, let name, let biography, let avatarUrl, let facebookUrl, let tumblrUrl, let googlePlusUrl, let twitterUrl, let instagramUrl, let pinterestUrl, let youtubeUrl, let linkedinUrl, let wordpressUrl, let websiteUrl):
      return PenNameAPI.updatePostBody(identifier: identifier, name: name, biography: biography, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl)
    case .updatePreference(let preference, let value):
      return UserAPI.updatePostBody(preference: preference, value: value)
    case .posts(_, let type):
      return GeneralAPI.postsParameters(type: type)
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .penNames, .wit, .unwit, .absolute, .discover, .onBoarding, .follow, .unfollow, .content, .followers, .editions:
      return nil
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

  var includes: [String]? {
    switch self {
    case .user, .register:
      return [PenName.resourceType]
    case .newsFeed:
      return ["pen-name", "contributors", "commenters"]
    case .content(_, let include):
      return include
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
