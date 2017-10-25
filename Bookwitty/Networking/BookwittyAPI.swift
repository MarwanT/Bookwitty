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
  case search(filter: Filter?, page: (number: String?, size: String?)?, includeFacets: Bool)
  case createPenName(name: String, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?)
  case updatePenName(identifier: String, name: String?, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?)
  case batch(identifiers: [String])
  case batchPenNames(identifiers: [String])
  case updatePreference(preference: String, value: String)
  case penNames
  case comments(postIdentifier: String)
  case replies(commentIdentifier: String)
  case createComment(postIdentifier: String, comment: String, parentCommentIdentifier: String?)
  case removeComment(commentId: String)
  case witComment(identifier: String)
  case unwitComment(identifier: String)
  case dimComment(identifier: String)
  case undimComment(identifier: String)
  case wit(contentId: String)
  case unwit(contentId: String)
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
  case preferredFormats(bookIdentifier: String)
  case editions(identifier: String, formats: [String]?)
  case resetPassword(email: String)
  case penName(identifier: String)
  case penNameContent(identifier: String, status: PublishAPI.PublishStatus?)
  case penNameFollowers(identifier: String)
  case penNameFollowing(identifier: String)
  case status
  case resendAccountConfirmation
  case uploadPolicy(file: (name: String, size: Int), fileType: UploadAPI.FileType, assetType: UploadAPI.AssetType)
  case uploadMultipart(url: URL, parameters: [String : String]?, multipart: (data: Data, name: String))
  case votes(identifier: String)
  case report(identifier: String)
  case reportPenName(identifier: String)
  case createContent(title: String?, body: String?, status: PublishAPI.PublishStatus)
  case updateContent(id: String, title: String?, body: String?, imageURL: String?, shortDescription: String? , status: PublishAPI.PublishStatus?)
  case removeContent(contentIdentifier: String)
  case linkTag(contentIdentifier: String, tagIdentifier: String)
  case removeTag(contentIdentifier: String, tagIdentifier: String)
  case linkContent(contentIdentifier: String, topicIdentifier: String)
  case unlinkContent(contentIdentifier: String, topicIdentifier: String)
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
    case .search:
      path = "/search"
    case .createPenName:
      path = "/user/pen_names"
    case .updatePenName(let identifier, _, _, _, _, _, _, _, _, _, _, _, _, _, _):
      path = "/pen_names/\(identifier)"
    case .batch:
      path = "/content/batch"
    case .updatePreference:
      path = "/user/update_preference"
    case .penNames:
      path = "/user/pen_names"
    case .reportPenName(let identifier):
      path = "/pen_names/\(identifier)/report"
    case .comments(let postIdentifier):
      path = "/content/\(postIdentifier)/comments"
    case .replies(let commentIdentifier):
      path = "/comments/\(commentIdentifier)/children"
    case .createComment(let postIdentifier, _, _):
      path = "/content/\(postIdentifier)/comments"
    case .removeComment(let identifier):
      path = "/comments/\(identifier)"
    case .witComment(let identifier), .unwitComment(let identifier):
      path = "/comments/\(identifier)/wit"
    case .dimComment(let identifier), .undimComment(let identifier):
      path = "/comments/\(identifier)/dim"
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
    case .followPenName(let identifier):
        path = "/pen_names/\(identifier)/follow"
    case .unfollowPenName(let identifier):
        path = "/pen_names/\(identifier)/follow"
    case .content(let identifier, _):
      path = "/content/\(identifier)"
    case .createContent:
      path = "/content"
    case .updateContent(let id, _, _, _, _, _ ):
      path = "/content/\(id)"
    case .followers(let identifier):
      path = "/content/\(identifier)/followers"
    case .postsContent(let identifier, _):
      path = "/content/\(identifier)/content"
    case .posts(let identifier, _):
      path = "/content/\(identifier)/posts"
    case .postsLinkedContent(let identifier, _):
      path = "/content/\(identifier)/linked_content"
    case .editions(let identifier, _):
      path = "/content/\(identifier)/editions"
    case .votes(let identifier):
      path = "/content/\(identifier)/votes"
    case .report(let identifier):
      path = "/content/\(identifier)/report"
    case .preferredFormats(let bookIdentifier):
      path = "/content/\(bookIdentifier)/preferred_formats"
    case .resetPassword:
      path = "/user/reset_password"
    case .penNameContent(let identifier, _):
      path = "/pen_names/\(identifier)/content"
    case .penNameFollowers(let identifier):
      path = "/pen_names/\(identifier)/followers"
    case .penNameFollowing(let identifier):
      path = "/pen_names/\(identifier)/following"
    case .penName(let identifier):
      path = "/pen_names/\(identifier)"
    case .batchPenNames:
      path = "/pen_name/batch"
    case .status:
      path = "/status"
    case .resendAccountConfirmation:
      path = "/user/resend_confirmation"
    case .uploadPolicy:
      path = "/upload_policies"
    case .linkTag(let contentIdentifier, _):
      path = "/content/\(contentIdentifier)/relationships/tags"
    case .removeTag(let contentIdentifier, _):
      path = "/content/\(contentIdentifier)/relationships/tags"
    case .linkContent(let contentIdentifier, _):
      path = "/content/\(contentIdentifier)/relationships/topics"
    case .unlinkContent(let contentIdentifier, _):
      path = "/content/\(contentIdentifier)/relationships/topics"
    case .removeContent(let contentIdentifier):
      path = "/content/\(contentIdentifier)"
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
    case .oAuth, .refreshToken, .resendAccountConfirmation, .createPenName, .createContent, .linkTag, .linkContent:
      return .post
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .search, .penNames, .comments, .replies, .absolute, .discover, .onBoarding, .content, .followers, .posts, .editions, .penNameContent, .penNameFollowers, .penNameFollowing, .status, .penName, .postsContent, .postsLinkedContent, .votes, .preferredFormats:
      return .get
    case .register, .batch, .updatePreference, .wit, .follow, .resetPassword, .followPenName, .uploadPolicy, .uploadMultipart, .batchPenNames, .createComment, .witComment, .dimComment, .report, .reportPenName:
      return .post
    case .updateUser, .updatePenName, .updateContent:
      return .patch
    case .unwit, .unfollow, .unfollowPenName, .unwitComment, .undimComment, .removeComment, .removeTag, .unlinkContent, .removeContent:
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
    case .unlinkContent(_, let topicIdentifier):
      return ContentAPI.unlinkContentParameters(topicIdentifier)
    case .linkContent(_, let topicIdentifier):
      return ContentAPI.linkContentParameters(topicIdentifier)
    case .removeTag(_, let tagIdentifier):
      return TagAPI.removeTagParameters(tagIdentifier)
    case .linkTag(_, let tagIdentifier):
      return TagAPI.linkTagParameters(tagIdentifier)
    case .createContent(let title, let body, let status):
      return PublishAPI.createContentParameters(title: title, body: body, status: status)
    case .updateContent(_, let title, let body, let imageURL, let shortDescription, let status):
      return PublishAPI.updateContentParameters(title: title, body: body, imageURL: imageURL, shortDescription: shortDescription, status: status)
    case .batch(let identifiers):
      return UserAPI.batchPostBody(identifiers: identifiers)
    case .batchPenNames(let identifiers):
      return GeneralAPI.batchPenNamesPostBody(identifiers: identifiers)
    case .register(let firstName, let lastName, let email, let dateOfBirth, let country, let password, let language):
      return UserAPI.registerPostBody(firstName: firstName, lastName: lastName, email: email, dateOfBirth: dateOfBirth, country: country, password: password, language: language)
    case .updateUser(let identifier, let firstName, let lastName, let dateOfBirth, let email, let currentPassword, let password, let country, let badges, let preferences):
      return UserAPI.updatePostBody(identifier: identifier, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, email: email, currentPassword: currentPassword, password: password, country: country, badges: badges, preferences: preferences)
    case .search(let filter, let page, let includeFacets):
      return SearchAPI.parameters(filter: filter, page: page, includeFacets: includeFacets)
    case .createPenName(let name, let biography, let avatarId, let avatarUrl, let facebookUrl, let tumblrUrl, let googlePlusUrl, let twitterUrl, let instagramUrl, let pinterestUrl, let youtubeUrl, let linkedinUrl, let wordpressUrl, let websiteUrl):
      return PenNameAPI.createPostBody(name: name, biography: biography, avatarId: avatarId, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl)
    case .updatePenName(let identifier, let name, let biography, let avatarId, let avatarUrl, let facebookUrl, let tumblrUrl, let googlePlusUrl, let twitterUrl, let instagramUrl, let pinterestUrl, let youtubeUrl, let linkedinUrl, let wordpressUrl, let websiteUrl):
      return PenNameAPI.updatePostBody(identifier: identifier, name: name, biography: biography, avatarId: avatarId, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl)
    case .penNameContent(_, let status):
      return PenNameAPI.penNameContent(with: status)
    case .updatePreference(let preference, let value):
      return UserAPI.updatePostBody(preference: preference, value: value)
    case .posts(_, let type):
      return GeneralAPI.postsParameters(type: type)
    case .votes:
      return GeneralAPI.votesParameters()
    case .postsLinkedContent(_, let type):
      return GeneralAPI.postsParameters(type: type)
    case .resetPassword(let email):
      return UserAPI.resetPasswordBody(email: email)
    case .postsContent(_ , let page):
      return GeneralAPI.postsContentParameters(page: page)
    case .createComment(_, let comment, let parentCommentIdentifier):
      return CommentAPI.createCommentBody(comment: comment, parentCommentIdentifier: parentCommentIdentifier)
    case .uploadPolicy(let file, let fileType, let assetType):
      return UploadAPI.uploadPolicyParameters(file: file, fileType: fileType, assetType: assetType)
    case .editions(_, let formats):
      return ContentAPI.editionsFilterParameters(formats: formats)
    case .allAddresses, .user, .bookStore, .categoryCuratedContent, .newsFeed, .penNames, .wit, .unwit, .absolute, .discover, .onBoarding, .follow, .unfollow, .content, .followers, .penNameContent, .penNameFollowers, .penNameFollowing, .unfollowPenName, .followPenName, .status, .resendAccountConfirmation, .penName, .uploadMultipart, .comments, .replies, .witComment, .unwitComment, .dimComment, .undimComment, .preferredFormats, .report, .reportPenName, .removeComment, .removeContent:
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
    case .batch, .search, .discover, .penNameContent, .penNameFollowing, .posts, .createComment:
      return ["pen-name"]
    case .comments, .replies:
      return ["pen-name", "children", "children.pen-name"]
    case .newsFeed:
      return ["pen-name", "contributors", "commenters", "top-votes", "top-votes.pen-name", "top-comments", "top-comments.pen-name"]
    case .postsLinkedContent:
      return ["pen-name", "contributors"]
    case .content(_, let include):
      var includes = include ?? []
      if !includes.contains("pen-name") {
        includes.append("pen-name")
      }
      return include
    case .batchPenNames:
      return []
    case .absolute, .removeComment, .uploadPolicy:
      return nil
    default:
      return ["pen-name"]
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
