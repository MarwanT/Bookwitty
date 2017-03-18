//
//  Media.swift
//  iframely
//
//  Created by charles on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Media {
  var relationships: [String]?
  var url: URL?

  internal init(json: JSON) {
    self.relationships = json["rel"].arrayObject as? [String]
    self.url = URL(string: json["href"].stringValue)
  }
}
