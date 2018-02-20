//
//  PenNameViewModel.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class PenNameViewModel {
  private(set) var penName: PenName?
  private var user: User?

  private var updateRequest: Cancellable? = nil

  func penDisplayName() -> String {
    return penName?.name ?? ""
  }

  func penBiography() -> String {
    return penName?.biography ?? ""
  }

  func penAvatarUrl() -> String? {
    return penName?.avatarUrl
  }

  func initializeWith(penName: PenName?, andUser user: User?) {
    self.penName = penName
    self.user = user
  }

  func createPenName(name: String, biography: String?, avatarId: String?, completion: ((Bool, PenName?, BookwittyAPIError?)->())?) {
    _ = PenNameAPI.createPenName(name: name, biography: biography, avatarId: avatarId, avatarUrl: nil, facebookUrl: nil, tumblrUrl: nil, googlePlusUrl: nil, twitterUrl: nil, instagramUrl: nil, pinterestUrl: nil, youtubeUrl: nil, linkedinUrl: nil, wordpressUrl: nil, websiteUrl: nil) {
      (success: Bool, penName: PenName?, error: BookwittyAPIError?) in
      defer {
        completion?(success, penName, error)
      }

      if let penName = penName {
        UserManager.shared.append(penName: penName)
      }
    }
  }

  func updatePenNameIfNeeded(name: String?, biography: String?, avatarId: String?, completion: ((Bool, BookwittyAPIError?)->())?) {
    guard let penName = penName, let identifier = penName.id else {
      completion?(false, nil)
      return
    }

    if updateRequest != nil {
      updateRequest?.cancel()
    }

    updateRequest = PenNameAPI.updatePenName(identifier: identifier, name: name, biography: biography, avatarId: avatarId, avatarUrl: nil, facebookUrl: nil, tumblrUrl: nil, googlePlusUrl: nil, twitterUrl: nil, instagramUrl: nil, pinterestUrl: nil, youtubeUrl: nil, linkedinUrl: nil, wordpressUrl: nil, websiteUrl: nil) {
      (success: Bool, penName: PenName?, error: BookwittyAPIError?) in
      defer {
        completion?(success, error)
      }
      
      if let penName = penName {
        self.penName = penName
        if let index = self.user?.penNames?.index(where: { $0.id == penName.id }) {
          self.user?.penNames?[index] = penName
        }
      }
    }
  }
  
  func upload(image: UIImage?, completion: @escaping (_ success: Bool, _ imageId: String?) -> Void) {
    guard let image = image, let data = image.dataForPNGRepresentation() else {
      completion(false, nil)
      return
    }
    
    _ = UploadAPI.uploadPolicy(file: ("profile", size: data.count), fileType: UploadAPI.FileType.image, assetType: UploadAPI.AssetType.profile) {
      (success, policy, error) in
      guard success, let policy = policy, let url = URL(string: policy.uploadUrl ?? "") else {
        completion(false, nil)
        return
      }
      
      let parameters: [String : String] = (policy.form as? [String : String]) ?? [:]
      _ = UtilitiesAPI.upload(url: url, paramters: parameters, multipart: (data: data, name: "file"), completion: {
        (success, error) in
        completion(success, policy.uuid)
      })
    }
  }
}
