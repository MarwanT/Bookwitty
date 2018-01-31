//
//  Upload+API.swift
//  Bookwitty
//
//  Created by charles on 3/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

public struct UploadAPI {
  public enum FileType: String {
    case image = "image/jpeg"
  }

  public enum AssetType: String {
    case profile = "profile"
    case feature = "feature"
    case inline = "inline"
  }

  static func uploadPolicy(file: (name: String, size: Int), fileType: FileType, assetType: AssetType, completion: @escaping (_ success: Bool, _ policy: UploadPolicy?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: BookwittyAPI.uploadPolicy(file: file, fileType: fileType, assetType: assetType)) {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var error: BookwittyAPIError? = error
      var uploadPolicy: UploadPolicy? = nil
      defer {
        completion(success, uploadPolicy, error)
      }
      
      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }


      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }

      uploadPolicy = UploadPolicy.parseData(data: data)
    }
  }
}

extension UploadAPI {
  static func uploadPolicyParameters(file: (name: String, size: Int), fileType: FileType, assetType: AssetType) -> [String : Any]? {
    return [
      "data": [
        "attributes": [
          "content_type": fileType.rawValue,
          "file_size": file.size,
          "file_name": file.name,
          "asset_type": assetType.rawValue
        ]
      ]
    ]
  }
}
