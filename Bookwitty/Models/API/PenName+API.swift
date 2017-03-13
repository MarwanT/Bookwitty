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

  public static func updatePenName(identifier: String, name: String?, biography: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?, completionBlock: @escaping (_ success: Bool, _ penName: PenName?, _ error: BookwittyAPIError?)->()) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.updatePenName(identifier: identifier, name: name, biography: biography, avatarUrl: avatarUrl, facebookUrl: facebookUrl, tumblrUrl: tumblrUrl, googlePlusUrl: googlePlusUrl, twitterUrl: twitterUrl, instagramUrl: instagramUrl, pinterestUrl: pinterestUrl, youtubeUrl: youtubeUrl, linkedinUrl: linkedinUrl, wordpressUrl: wordpressUrl, websiteUrl: websiteUrl), completion: {
      (data, statusCode, response, error) in
      var success: Bool = false
      var penName: PenName? = nil
      var error: BookwittyAPIError? = error
      defer {
        completionBlock(success, penName, error)
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
}

//MARK: - Moya Needed parameters
extension PenNameAPI {
  static func updatePostBody(identifier: String, name: String?, biography: String?, avatarUrl: String?, facebookUrl: String?, tumblrUrl: String?, googlePlusUrl: String?, twitterUrl: String?, instagramUrl: String?, pinterestUrl: String?, youtubeUrl: String?, linkedinUrl: String?, wordpressUrl: String?, websiteUrl: String?) -> [String : Any]? {
    let penName = PenName()
    penName.id = identifier
    penName.name = name
    penName.biography = biography
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
