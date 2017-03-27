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
  }

  public static func uploadPolicy(file: (name: String, size: Int), fileType: FileType, assetType: AssetType, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    let successStatusCode: Int = 200

    return signedAPIRequest(target: BookwittyAPI.uploadPolicy(file: file, fileType: fileType, assetType: assetType)) {
      (data, statusCode, response, error) in
      var success: Bool = statusCode == successStatusCode
      var error: BookwittyAPIError? = error
      
      defer {
        completion(success, error)
      }
      
      guard statusCode == successStatusCode else {
        error = BookwittyAPIError.invalidStatusCode
        return
      }

      //TODO: Parse the data
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
