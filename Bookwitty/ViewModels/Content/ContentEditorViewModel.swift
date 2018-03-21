//
//  ContentViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class ContentEditorViewModel  {
  var linkedTags: [Tag] = []
  var linkedPages: [ModelCommonProperties] = []
  private(set) var originalHashValue: Int = 0
  private(set) var latestHashValue: Int = 0
  private(set) var currentRequest: Cancellable?
  var publishable: Bool {
    return self.prelink == nil && self.currentPost.id != nil && !self.hasPendingUploadingRequest
  }
  private var pendingUploadRequests: [String] = []
  
  fileprivate var prelink: String?
  var hasPendingUploadingRequest: Bool {
    return self.pendingUploadRequests.count > 0
  }
  
  var currentPost: CandidatePost!
  
  var isNewlyCreated: Bool {
    return self.originalHashValue == NSNotFound
  }

  var needsLocalSync: Bool {
    return self.latestHashValue != self.currentPost.hash
  }
  
  var needsRemoteSync: Bool {
    guard !needsLocalSync else {
      return true
    }

    return self.originalHashValue != self.latestHashValue
  }
  
  func initialize(with candidatPost: CandidatePost, prelink: String? = nil) -> Void {
    self.set(candidatPost)
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
  
  func set(_ currentPost: CandidatePost, clean: Bool = true) {
    self.currentPost = currentPost
    self.latestHashValue = currentPost.hash
    if clean {
      self.originalHashValue = currentPost.hash
    }
    
    //check if we have linked tags/topics
    self.getLinkedTags()
    self.getLinkedPages()
  }

  func getLinkedTags() {
    
    guard let id = self.currentPost.id else {
      return
    }
    
    _ = ContentAPI.linkedTags(to: id) { (success, tags, error) in
      guard success else {
        return
      }
      
      self.currentPost.tags = tags
      self.linkedTags = tags ?? []
    }
  }
  
  func getLinkedPages() {
    
    guard let id = self.currentPost.id else {
      return
    }
    // [ModelResource]?
    _ = ContentAPI.linkedPages(to: id) { (success, pages, _, error) in
      
      guard success else {
        return
      }
      
      guard let pages = pages else {
        return
      }
      
      self.linkedPages = pages.flatMap { $0 as? ModelCommonProperties }
    }
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

  func preparePostForPublish(with defaultValue:(title: String, description: String?, imageURL: String?)? = nil) {
    self.currentPost.status = PublishAPI.PublishStatus.public.rawValue
    self.currentPost.title = self.currentPost.title ?? defaultValue?.title
    self.currentPost.shortDescription = self.currentPost.shortDescription ?? defaultValue?.description
    self.currentPost.imageUrl = self.currentPost.imageUrl ?? defaultValue?.imageURL
  }
  

  fileprivate func createContent(with completion:((_ success: Bool) -> Void)? = nil) {
    self.resetPreviousRequest()
    //WORKAROUND: the API doesn't create a content unless we send a title
    let contentTile = self.currentPost.title.isEmptyOrNil() ? Strings.untitled() : self.currentPost.title
    let contentBody = self.currentPost.body ?? ""
    self.currentRequest = PublishAPI.createContent(title: contentTile, body: contentBody) { (success, candidatePost, error) in
      defer { self.currentRequest = nil; completion?(success) }
      
      guard success, let candidatePost = candidatePost else {
        return
      }
      //Workaround due to the API default behavior
      let imageUrlValue = self.currentPost.imageUrl
      self.set(candidatePost)
      if imageUrlValue == nil {
       self.currentPost.imageUrl = nil
      }
    }
  }
  
  func updateContent(with defaultValues: (title: String, description: String?, imageURL: String?), completion: ((_ success: Bool) -> Void)? = nil) {
    guard let currentPost = self.currentPost, let id = currentPost.id else {
      completion?(false)
      return
    }

    let title = currentPost.title ?? defaultValues.title
    let shortDescription = currentPost.shortDescription ?? defaultValues.description
    let imageURL = currentPost.imageUrl ?? defaultValues.imageURL

    self.resetPreviousRequest()
    let status = PublishAPI.PublishStatus(rawValue: self.currentPost.status ?? "") ?? PublishAPI.PublishStatus.draft
    self.currentRequest = PublishAPI.updateContent(id: id, title: title, body: currentPost.body, imageIdentifier: imageURL, shortDescription: shortDescription, status: status, completion: { (success, candidatePost, error) in
      defer { self.currentRequest = nil; completion?(success) }
      guard success, let candidatePost = candidatePost else {
        return
      }

      try? self.deleteLocalDraft()

      //Workaround due to the API default behavior
      let imageUrlValue = self.currentPost.imageUrl
      self.set(candidatePost)
      if imageUrlValue == nil {
        self.currentPost.imageUrl = nil
      }
    })
  }
  
  private func updateContentLocally(_ completion:((_ success: Bool) -> Void)? = nil)  {
    guard let post = self.currentPost as? Text else {
      completion?(false)
      return
    }
    
    if let serialized = post.serializeData(options:  [.IncludeID, .OmitNullValues]) {
      let json = JSON(serialized)
      do {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let dataPath = documentsDirectory.appendingPathComponent("content-editor")
          try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
          if let jsonString = json.rawString() {
            try jsonString.write(to: dataPath.appendingPathComponent("temp-draft").appendingPathExtension("txt"), atomically: true, encoding: .utf8)
            self.latestHashValue = self.currentPost.hash
            completion?(true)
          } else {
            completion?(false)
          }
        }
      } catch {
        completion?(false)
      }
    }
  }
  
  func deleteLocalDraft() throws {
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let dataPath = documentsDirectory.appendingPathComponent("content-editor").appendingPathComponent("temp-draft").appendingPathExtension("txt")
      try FileManager.default.removeItem(at: dataPath)
    }
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

  func dispatchContent(hasContent: Bool, _ completion:((_ created: ContentEditorViewController.DispatchStatus, _ success: Bool) -> Void)? = nil) {
    
    let newHashValue = self.currentPost.hash
    let latestHashValue = self.latestHashValue
    
    if self.currentPost.id == nil {
      if hasContent {
        self.createContent(with: { success in
          completion?(.create, success)
        })
      } else {
        completion?(.noChanges, true) // no Change
      }
    } else {
      self.dispatchPrelinkIfNeeded()
      if newHashValue != latestHashValue {
        self.updateContentLocally({ (success) in
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

  func deletePost(_ closure: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let identifier = self.currentPost.id else {
        closure(true, nil)
        return
    }

    _ = PublishAPI.removeContent(contentIdentifier: identifier) { (success, error) in
      try? self.deleteLocalDraft()
      closure(success, error)
    }
  }
}
