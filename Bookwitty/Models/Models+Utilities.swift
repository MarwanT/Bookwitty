//
//  Models+Utilities.swift
//  Bookwitty
//
//  Created by Marwan  on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Spine

extension Resource {
  var canonicalURL: URL? {
    guard let urlString = self.links?["canonical-url"] as? String,
      let url = URL(string: urlString) else {
        return nil
    }
    return url
  }
}
