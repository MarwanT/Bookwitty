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
  var linkedPages: [ModelCommonProperties] = []
  private(set) var latestHashValue: Int = 0
  private(set) var currentRequest: Cancellable?
  
  private var pendingUploadRequests: [String] = []
  
  fileprivate var prelink: String?
  var hasPendingUploadingRequest: Bool {
    return self.pendingUploadRequests.count > 0
  }
  
  var currentPost: CandidatePost!
  
  func initialize(with candidatPost: CandidatePost, prelink: String? = nil) -> Void {
    self.currentPost = candidatPost
    self.prelink = prelink
  }
  
  func addUploadRequest(_ request: String) {
    pendingUploadRequests.append(request)
  }
  
  func removeUploadRequest(_ request: String) {
    if let index = pendingUploadRequests.index(where: { $0 == request }) {
      pendingUploadRequests.remove(at: index)
    }
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
  

  fileprivate func createContent(with completion:((_ success: Bool) -> Void)? = nil) {
    guard let body = self.currentPost.body, !body.isEmpty else {
      return
    }
    self.resetPreviousRequest()
    //WORKAROUND: the API doesn't create a content unless we send a title
    let contentTile = self.currentPost.title.isEmptyOrNil() ? "Untitled" : self.currentPost.title
    self.currentRequest = PublishAPI.createContent(title: contentTile, body: self.currentPost.body) { (success, candidatePost, error) in
      defer { self.currentRequest = nil; completion?(success) }
      
      guard success, let candidatePost = candidatePost else {
        return
      }
      self.set(candidatePost)
      
    }
  }
  
  fileprivate func updateContent(with completion:((_ success: Bool) -> Void)? = nil) {
    guard let currentPost = self.currentPost, let id = currentPost.id else {
      return
    }
    self.resetPreviousRequest()
    let status = PublishAPI.PublishStatus(rawValue: self.currentPost.status ?? "") ?? PublishAPI.PublishStatus.draft
    self.currentRequest = PublishAPI.updateContent(id: id, title: currentPost.title, body: currentPost.body, imageURL: currentPost.imageUrl, shortDescription: currentPost.shortDescription, status: status, completion: { (success, candidatePost, error) in
      defer { self.currentRequest = nil; completion?(success) }
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

      guard let resource = DataManager.shared.fetchResource(with: prelink) as? ModelCommonProperties else {
        return
      }

      self.linkedPages.append(resource)
    })
  }

  func dispatchContent(with completion:((_ created: ContentEditorViewController.DispatchStatus, _ success: Bool) -> Void)? = nil) {
    
    let newHashValue = self.currentPost.hash
    let latestHashValue = self.latestHashValue
    
    if self.currentPost.id == nil {
      self.createContent(with: { success in
        completion?(.create, success)
      })
    } else {
      self.dispatchPrelinkIfNeeded()
      if newHashValue != latestHashValue {
        self.updateContent(with: { success in
          completion?(.update, success)
        })
      } else {
        completion?(.noChanges, true) // no Change
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
