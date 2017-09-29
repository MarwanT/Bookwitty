//
//  UploadPolicy.swift
//  Bookwitty
//
//  Created by charles on 3/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class UploadPolicy: Resource {
  var uploadUrl: String?
  var asset: [String : Any]?
  var form: [String : Any]?

  var uuid: String? {
    return asset?["uuid"] as? String
  }
  
  var link: String? {
    return asset?["url"] as? String
  }

  override class var resourceType: ResourceType {
    return "upload-policies"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "uploadUrl": Attribute().serializeAs("upload_url"),
      "asset": Attribute().serializeAs("asset"),
      "form": Attribute().serializeAs("form"),
      ])
  }
}

extension UploadPolicy: Parsable {
  typealias AbstractType = UploadPolicy
}
