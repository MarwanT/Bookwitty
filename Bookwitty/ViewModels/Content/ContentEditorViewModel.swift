//
//  ContentViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Moya

class ContentEditorViewModel  {
  var linkedTags: [Tag] = []
  var linkedTopics: [Topic] = []
  private(set) var latestHashValue: Int = 0
  private(set) var currentRequest: Cancellable?

  fileprivate var prelink: String?

  var currentPost: CandidatePost!
  
  func initialize(with candidatPost: CandidatePost, prelink: String? = nil) -> Void {
    self.currentPost = candidatPost
    self.prelink = prelink
  }
  
  func set(_ currentPost: CandidatePost) {
    self.currentPost = currentPost
    self.latestHashValue = currentPost.hash
  }
  
  
  var getCurrentPost: CandidatePost {
    return self.currentPost
  }
  
  func resetPreviousRequest() {
    
    if let previousRequest = currentRequest {
      previousRequest.cancel()
      currentRequest = nil
    }
  }
  
  fileprivate func createContent() {
    self.resetPreviousRequest()
    self.currentRequest = PublishAPI.createContent(title: self.currentPost.title, body: self.currentPost.body) { (success, candidatePost, error) in
      defer { self.currentRequest = nil }
      
      guard success, let candidatePost = candidatePost else {
        return
      }
      self.set(candidatePost)
    }
  }
  
  fileprivate func updateContent() {
    guard let currentPost = self.currentPost, let id = currentPost.id else {
      return
    }
    self.resetPreviousRequest()
    let status = PublishAPI.PublishStatus(rawValue: self.currentPost.status ?? "") ?? PublishAPI.PublishStatus.draft
    self.currentRequest = PublishAPI.updateContent(id: id, title: currentPost.title, body: currentPost.body, imageURL: currentPost.imageUrl, shortDescription: currentPost.shortDescription, status: status, completion: { (success, candidatePost, error) in
      defer { self.currentRequest = nil }
      guard success, let candidatePost = candidatePost else {
        return
      }
      self.set(candidatePost)
    })
  }
  
  fileprivate func dispatchPrelinkIfNeeded() {
    guard let prelink = prelink,
      let identifier = self.currentPost?.id else {
      return
    }
    _ = ContentAPI.linkContent(for: identifier, with: prelink, completion: { (success, error) in
      guard success else {
        return
      }

      self.prelink = nil
    })
  }

  func dispatchContent() {
    
    let newHashValue = self.currentPost.hash
    let latestHashValue = self.latestHashValue
    
    if self.currentPost.id == nil {
      self.createContent()
    } else {
      self.dispatchPrelinkIfNeeded()
      if newHashValue != latestHashValue {
        self.updateContent()
      }
    }
    
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
