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
