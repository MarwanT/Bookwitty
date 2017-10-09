//
//  Tag+API.swift
//  Bookwitty
//
//  Created by ibrahim on 10/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

public struct TagAPI {
  
}

extension TagAPI {
  static func linkTag(_ identifier: String) -> [String:Any]? {
    let dictionary = [
      "data" : [
        "attributes" : [
          "type" : Tag.resourceType,
          "id" : identifier,
        ]
      ]
    ]
    return dictionary
  }
}
