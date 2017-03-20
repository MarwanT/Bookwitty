//
//  Thumbnail.swift
//  iframely
//
//  Created by charles on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Thumbnail {
  var size: CGSize?
  var length: Int?
  var url: URL?

  internal init(json: JSON) {
    self.size = CGSize(width: json["media"]["width"].doubleValue, height: json["media"]["height"].doubleValue)
    self.length = json["content_length"].int
    self.url = URL(string: json["href"].stringValue)
  }
}
