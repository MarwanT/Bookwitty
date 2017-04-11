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
  case oAuth(credentials: (username: String, password: String)?)
  case refreshToken(refreshToken: String)
  case allAddresses
  case register(firstName: String, lastName: String, email: String, dateOfBirthISO8601: String?, countryISO3166: String, password: String, language: String)
  case user
  case updateUser(identifier: String, firstName: String?, lastName: String?, dateOfBirth: String?, email: String?, currentPassword: String?, password: String?, country: String?, badges: [String : Any]?, preferences: [String : Any]?)
  case bookStore
  case categoryCuratedContent(categoryIdentifier: String)
  case newsFeed()
  case Search(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?)
  case updatePenName(identifier: String, name: String?, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?)
  case batch(identifiers: [String])
  case updatePreference(preference: String, value: String)
  case penNames
  case wit(contentId: String)
  case unwit(contentId: String)
  case dim(contentId: String)
  case undim(contentId: String)
  case absolute(url: URL)
  case discover
  case onBoarding
  case follow(identifier: String)
  case unfollow(identifier: String)
  case followPenName(identifier: String)
  case unfollowPenName(identifier: String)
  case postsContent(identifier: String, page: (number: String?, size: String?)?)
  case content(identifier: String, include: [String]?)
  case followers(identifier: String)
  case posts(identifier: String, type: [String]?)
  case postsLinkedContent(identifier: String, type: [String]?)
  case editions(identifier: String)
  case resetPassword(email: String)
  case penName(identifier: String)
  case penNameContent(identifier: String)
  case penNameFollowers(identifier: String)
  case penNameFollowing(identifier: String)
  case status
  case resendAccountConfirmation
  case uploadPolicy(file: (name: String, size: Int), fileType: UploadAPI.FileType, assetType: UploadAPI.AssetType)
  case uploadMultipart(url: URL, parameters: [String : String]?, multipart: (data: Data, name: String))
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
    case .uploadMultipart(let url, _, _):
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
      components?.scheme = "https"
      return components?.url ?? url
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
    case .updatePenName(let identifier, _, _, _, _, _, _, _, _, _, _, _, _, _, _):
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
    case .dim(let contentId):
      path = "/content/\(contentId)/dim"
    case .undim(let contentId):
      path = "/content/\(contentId)/dim"
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
    case .followPenName(let identifier):
        path = "/pen_names/\(identifier)/follow"
    case .unfollowPenName(let identifier):
        path = "/pen_names/\(identifier)/follow"
    case .content(let identifier, _):
      path = "/content/\(identifier)"
    case .followers(let identifier):
      path = "/content/\(identifier)/followers"
    case .postsContent(let identifier, _):
      path = "/content/\(identifier)/content"
    case .posts(let identifier, _):
      path = "/content/\(identifier)/posts"
    case .postsLinkedContent(let identifier, _):
      path = "/content/\(identifier)/linked_content"
    case .editions(let identifier):
      path = "/content/\(identifier)/editions"
    case .resetPassword:
      path = "/user/reset_password"
    case .penNameContent(let identifier):
      path = "/pen_names/\(identifier)/content"
    case .penNameFollowers(let identifier):
      path = "/pen_names/\(identifier)/followers"
    case .penNameFollowing(let identifier):
      path = "/pen_names/\(identifier)/following"
    case .penName(let identifier):
      path = "/pen_names/\(identifier)"
    case .status:
      path = "/status"
    case .resendAccountConfirmation:
      path = "/user/resend_confirmation"
    case .uploadPolicy:
      path = "/upload_policies"
    case .uploadMultipart:
      /*
      * Uploading to Amazon S3 servers, 
      * upload absolute url is provided as parameter
      */
      return ""
    }
    
    return apiBasePath + apiVersion + path
  }
  
  public var method: Moya.Method {
    switch self {
    case .oAuth, .refreshToken, .resendAccountConfirmation:
      return .post
  case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .Search, .penNames, .absolute, .discover, .onBoarding, .content, .followers, .posts, .editions, .penNameContent, .penNameFollowers, .penNameFollowing, .status, .penName, .postsContent, .postsLinkedContent:
      return .get
    case .register, .batch, .updatePreference, .wit, .follow, .dim, .resetPassword, .followPenName, .uploadPolicy, .uploadMultipart:
      return .post
    case .updateUser, .updatePenName:
      return .patch
    case .unwit, .unfollow, .undim, .unfollowPenName:
      return .delete
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .oAuth(let credentials):
      let params: [String: Any]
      if let credentials = credentials {
        params = [
          "client_id": AppKeys.shared.apiKey,
          "client_secret": AppKeys.shared.apiSecret,
          "username": credentials.username,
          "password":  credentials.password,
          "grant_type": "password",
          "scopes": "openid email profile"
        ]
      } else {
        params = [
          "client_id": AppKeys.shared.apiKey,
          "client_secret": AppKeys.shared.apiSecret,
          "grant_type": "client_credentials",
          "scopes": "openid email profile"
        ]
      }
      return params
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
    case .updatePenName(let identifier, let name, let biography, let avatarId, let avatarUrl, let facebookUrl, let tumblrUrl, let googlePlusUrl, let twitterUrl, let instagramUrl, let pinterestUrl, let youtubeUrl, let linkedinUrl, let wordpressUrl, let websiteUrl):
      return PenNameAPI.updatePostBody(identifier: identifier, name: name, biography: biography, avatarId: avatarId, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl)
    case .updatePreference(let preference, let value):
      return UserAPI.updatePostBody(preference: preference, value: value)
    case .posts(_, let type):
      return GeneralAPI.postsParameters(type: type)
    case .postsLinkedContent(_, let type):
      return GeneralAPI.postsParameters(type: type)
    case .resetPassword(let email):
      return UserAPI.resetPasswordBody(email: email)
    case .postsContent(_ , let page):
      return GeneralAPI.postsContentParameters(page: page)
    case .uploadPolicy(let file, let fileType, let assetType):
      return UploadAPI.uploadPolicyParameters(file: file, fileType: fileType, assetType: assetType)
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .penNames, .wit, .unwit, .absolute, .discover, .onBoarding, .follow, .unfollow, .content, .followers, .editions, .dim, .undim, .penNameContent, .penNameFollowers, .penNameFollowing, .unfollowPenName, .followPenName, .status, .resendAccountConfirmation, .penName, .uploadMultipart:
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
    case .uploadMultipart(_, let parameters, let multipart):
      /* Discussion
       * Amazon Requires the parameters to be appended before the `file`
       * [DO NOT] change the order, it would break the amazon update
       */
      var multipartArray: [MultipartFormData] = []
      if let parameters = parameters {
        parameters.forEach({ (kvp: (key: String, value: String)) in
          if let valueData: Data = kvp.value.data(using: .utf8) {
            multipartArray.append(MultipartFormData(provider: .data(valueData), name: kvp.key))
          }
        })
      }
      multipartArray.append(MultipartFormData(provider: .data(multipart.data), name: multipart.name))
      return .upload(.multipart(multipartArray))
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
    case .batch, .Search, .discover, .penNameContent, .penNameFollowing, .posts, .postsLinkedContent:
      return ["pen-name"]
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
