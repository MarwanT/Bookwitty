//
//  ContentViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ContentEditorViewModel  {
  
  var currentPost: CandidatePost!
  
  func initialize(with candidatPost: CandidatePost) -> Void {
    self.currentPost = candidatPost
  }
  
  func set(_ currentPost: CandidatePost) {
    self.currentPost = currentPost
  }
  
  
  var getCurrentPost: CandidatePost {
    return self.currentPost
  }
  
  func upload(image: UIImage?, completion: @escaping (_ success: Bool, _ imageId: String?) -> Void) {
    guard let image = image, let data = image.dataForPNGRepresentation() else {
      completion(false, nil)
      return
    }
    
    let fileName = UUID().uuidString
    _ = UploadAPI.uploadPolicy(file: (fileName, size: data.count), fileType: UploadAPI.FileType.image, assetType: UploadAPI.AssetType.content) {
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
