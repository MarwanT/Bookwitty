//
//  PostPreviewViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/12.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PostPreviewViewModel {
  var candidatePost: CandidatePost!

  func initialize(with post: CandidatePost) {
    self.candidatePost = post
  }

  func upload(image: UIImage?, completion: @escaping (_ success: Bool, _ imageId: String?) -> Void) {
    guard let image = image, let data = image.dataForPNGRepresentation() else {
      completion(false, nil)
      return
    }

    let fileName = UUID().uuidString
    _ = UploadAPI.uploadPolicy(file: (fileName, size: data.count), fileType: UploadAPI.FileType.image, assetType: UploadAPI.AssetType.inline) {
      (success, policy, error) in
      guard success, let policy = policy, let url = URL(string: policy.uploadUrl ?? "") else {
        completion(false, nil)
        return
      }

      let parameters: [String : String] = (policy.form as? [String : String]) ?? [:]
      _ = UtilitiesAPI.upload(url: url, paramters: parameters, multipart: (data: data, name: "file"), completion: {
        (success, error) in
        completion(success, policy.link)
      })
    }
  }
}
