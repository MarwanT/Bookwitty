//
//  Publish+API.swift
//  Bookwitty
//
//  Created by ibrahim on 10/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

public struct PublishAPI {
  public enum PublishStatus: String {
    case draft = "draft"
    case `public` = "public"
  }
}
