//
//  PostPreviewViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/12.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PostPreviewViewModel {
  fileprivate var maximumImageDataCount: Int = 12582912
  
  var candidatePost: CandidatePost!
  var defaultValues: (title: String, description: String?, image: String?)!
  
  func initialize(with post: CandidatePost, and defaultValues:(title: String, description: String?, image: String?)) {
    self.candidatePost = post
    self.defaultValues = defaultValues
  }
  
  func postValues() -> (title: String?, shortDescription: String?, penName: String?, url: URL?, imageUrl: String?) {
    let title = candidatePost.title ?? defaultValues.title
    let shortDescription = candidatePost.shortDescription ?? defaultValues.description
    let penName = candidatePost.penName?.name
    let url = candidatePost.penName?.url
    let imageUrl = candidatePost.imageUrl ?? defaultValues.image
    return (title, shortDescription, penName, url, imageUrl)
  }

  func upload(image: UIImage?, completion: @escaping (_ success: Bool, _ imageIdentifier: String?, _ imageLink: String?) -> Void) {
    guard let image = image else {
      completion(false, nil, nil)
      return
    }
    
    generateCandidateImage(for: image) { (uploadedImage) in
      guard let uploadedImage = uploadedImage,
        let data = uploadedImage.dataForPNGRepresentation() else {
        completion(false, nil, nil)
        return
      }
      
      let fileName = UUID().uuidString
      _ = UploadAPI.uploadPolicy(file: (fileName, size: data.count), fileType: UploadAPI.FileType.image, assetType: UploadAPI.AssetType.feature) {
        (success, policy, error) in
        guard success, let policy = policy, let url = URL(string: policy.uploadUrl ?? "") else {
          completion(false, nil, nil)
          return
        }
        
        let parameters: [String : String] = (policy.form as? [String : String]) ?? [:]
        _ = UtilitiesAPI.upload(url: url, paramters: parameters, multipart: (data: data, name: "file"), completion: {
          (success, error) in
          guard success, let identifier = self.candidatePost.id else {
            completion(success, nil, nil)
            return
          }
          
          _ = PublishAPI.updateContent(id: identifier, title: nil, body: nil, imageIdentifier: policy.uuid, shortDescription: nil, completion: {
            (success, post, error) in
            completion(success, policy.uuid, policy.link)
          })
        })
      }
    }
  }
  
  private func generateCandidateImage(for image: UIImage, completion: @escaping (UIImage?) -> Void) {
    let resizingOperation = ImageResizingOperation(image: image, resizingCriteria: .maximumDataCount(maximumImageDataCount))
    resizingOperation.completionBlock = {
      completion(resizingOperation.image)
    }
    
    let queue = OperationQueue()
    queue.name = "Resizing Image Queue"
    queue.qualityOfService = QualityOfService.userInitiated
    queue.addOperation(resizingOperation)
  }
}
