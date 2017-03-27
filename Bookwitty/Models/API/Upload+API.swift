//
//  Upload+API.swift
//  Bookwitty
//
//  Created by charles on 3/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public struct UploadAPI {
  public enum FileType: String {
    case image = "image/jpeg"
  }

  public enum AssetType: String {
    case profile = "profile"
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
