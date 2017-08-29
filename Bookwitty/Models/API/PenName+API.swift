//
//  PenName+API.swift
//  Bookwitty
//
//  Created by charles on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

struct PenNameAPI {
  public static func getPenNames(completionBlock: @escaping (_ success: Bool, _ penNames: [PenName]?, _ error: BookwittyAPIError?)->()) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.penNames, completion: { (data: Data?, statusCode: Int?, response: URLResponse?, error: BookwittyAPIError?) in
      var penNames: [PenName]? = nil
      var error: BookwittyAPIError? = nil
      var success: Bool = false
      defer {
        completionBlock(success, penNames, error)
      }

      if let data = data {
        penNames = PenName.parseDataArray(data: data)?.resources
        success = penNames != nil

        if let penNames = penNames {
          UserManager.shared.penNames = penNames
        }
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func createPenName(name: String, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?, completionBlock: @escaping (_ success: Bool, _ penName: PenName?, _ error: BookwittyAPIError?)->()) -> Cancellable? {

    let successStatusCode = 201
    let errorStatusCode = 422

    return signedAPIRequest(target: BookwittyAPI.createPenName(name: name, biography: biography, avatarId: avatarId, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var penName: PenName? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, penName, error)
      }

      guard statusCode == successStatusCode else {
        if statusCode == errorStatusCode {
          error = BookwittyAPIError.penNameHasAlreadyBeenTaken
        } else {
          error = BookwittyAPIError.undefined
        }
        return
      }


      if let data = data {
        penName = PenName.parseData(data: data)
        UserManager.shared.replaceUpdated(penName: penName)
        success = penName != nil
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func updatePenName(identifier: String, name: String?, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?, completionBlock: @escaping (_ success: Bool, _ penName: PenName?, _ error: BookwittyAPIError?)->()) -> Cancellable? {

    let successStatusCode = 200
    let errorStatusCode = 422

    return signedAPIRequest(target: BookwittyAPI.updatePenName(identifier: identifier, name: name, biography: biography, avatarId: avatarId, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var penName: PenName? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, penName, error)
      }

      guard statusCode == successStatusCode else {
        if statusCode == errorStatusCode {
          error = BookwittyAPIError.penNameHasAlreadyBeenTaken
        } else {
          error = BookwittyAPIError.undefined
        }
        return
      }
      
      if let data = data {
        penName = PenName.parseData(data: data)
        UserManager.shared.replaceUpdated(penName: penName)
        success = penName != nil
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func penNameDetails(identifier: String, completionBlock: @escaping (_ success: Bool, _ penName: PenName?, _ error: BookwittyAPIError?)->()) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.penName(identifier: identifier), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var penName: PenName? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, penName, error)
      }

      if let data = data {
        penName = PenName.parseData(data: data)
        success = penName != nil
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func followers(contentIdentifier identifier: String, completionBlock: @escaping (_ success: Bool, _ penNames: [PenName]?, _ next: URL?, _ error: BookwittyAPIError?)->()) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.followers(identifier: identifier), completion: { (data: Data?, statusCode: Int?, response: URLResponse?, error: BookwittyAPIError?) in
      var penNames: [PenName]? = nil
      var next: URL? = nil
      var error: BookwittyAPIError? = nil
      var success: Bool = false
      defer {
        completionBlock(success, penNames, next, error)
      }

      if let data = data, let values = PenName.parseDataArray(data: data) {
        penNames = values.resources
        next = values.next
        success = penNames != nil
      } else {
        error = BookwittyAPIError.failToParseData
      }
    })
  }

  public static func penNameContent(identifier: String, completion: @escaping (_ success: Bool, _ resources: [ModelResource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.penNameContent(identifier: identifier)) {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        // Ensure the completion block is always called
        var success: Bool = false
        var completionError: BookwittyAPIError? = error
        var resources: [ModelResource]?
        var nextPage: URL?
        defer {
          DispatchQueue.main.async {
            completion(success, resources, nextPage, error)
          }
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

        // Parse Data
        guard let data = data,
          let parsedData = Parser.parseDataArray(data: data) else {
            return
        }

        resources = parsedData.resources
        success = parsedData.resources != nil
        completionError = nil
        nextPage = parsedData.next
      }
    }
  }

  public static func penNameFollowers(identifier: String, completion: @escaping (_ success: Bool, _ resources: [PenName]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.penNameFollowers(identifier: identifier)) {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        // Ensure the completion block is always called
        var success: Bool = false
        var completionError: BookwittyAPIError? = error
        var penNames: [PenName]?
        var nextPage: URL?
        defer {
          DispatchQueue.main.async {
            completion(success, penNames, nextPage, error)
          }
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

        // Parse Data
        guard let data = data,
          let parsedData = Parser.parseDataArray(data: data) else {
            return
        }

        if let resources = parsedData.resources {
          penNames = resources.flatMap({ $0 as? PenName })
        }

        success = penNames != nil
        completionError = nil
        nextPage = parsedData.next
      }
    }
  }

  public static func penNameFollowing(identifier: String, completion: @escaping (_ success: Bool, _ resources: [ModelResource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(
    target: BookwittyAPI.penNameFollowing(identifier: identifier)) {
      (data, statusCode, response, error) in
      DispatchQueue.global(qos: .background).async {
        // Ensure the completion block is always called
        var success: Bool = false
        var completionError: BookwittyAPIError? = error
        var resources: [ModelResource]?
        var nextPage: URL?
        defer {
          DispatchQueue.main.async {
            completion(success, resources, nextPage, error)
          }
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

        // Parse Data
        guard let data = data,
          let parsedData = Parser.parseDataArray(data: data) else {
            return
        }

        resources = parsedData.resources
        success = resources != nil
        completionError = nil
        nextPage = parsedData.next
      }
    }
  }

  static func report(identifier: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 204

    return signedAPIRequest(target: .reportPenName(identifier: identifier), completion: {
      (data, statusCode, response, error) in
      let success: Bool = statusCode == successStatusCode
      var error: BookwittyAPIError? = error

      defer {
        completion(success, error)
      }

      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }
    })
  }
}

//MARK: - Moya Needed parameters
extension PenNameAPI {
  static func createPostBody(name: String, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?) -> [String : Any]? {
    let penName = PenName()
    penName.name = name
    penName.biography = biography
    penName.avatarId = avatarId
    penName.avatarUrl = avatarUrl
    penName.facebookUrl = facebookUrl
    penName.tumblrUrl = tumblrUrl
    penName.googlePlusUrl = googlePlusUrl
    penName.twitterUrl = twitterUrl
    penName.instagramUrl = instagramUrl
    penName.pinterestUrl = pinterestUrl
    penName.youtubeUrl = youtubeUrl
    penName.linkedinUrl = linkedinUrl
    penName.wordpressUrl = wordpressUrl
    penName.websiteUrl = websiteUrl
    return penName.serializeData(options: [.OmitNullValues])
  }

  static func updatePostBody(identifier: String, name: String?, biography: String?, avatarId: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?) -> [String : Any]? {
    let penName = PenName()
    penName.id = identifier
    penName.name = name
    penName.biography = biography
    penName.avatarId = avatarId
    penName.avatarUrl = avatarUrl
    penName.facebookUrl = facebookUrl
    penName.tumblrUrl = tumblrUrl
    penName.googlePlusUrl = googlePlusUrl
    penName.twitterUrl = twitterUrl
    penName.instagramUrl = instagramUrl
    penName.pinterestUrl = pinterestUrl
    penName.youtubeUrl = youtubeUrl
    penName.linkedinUrl = linkedinUrl
    penName.wordpressUrl = wordpressUrl
    penName.websiteUrl = websiteUrl
    return penName.serializeData(options: [.IncludeID, .OmitNullValues])
  }
}
