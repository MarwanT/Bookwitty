//
//  URL+Utilities.swift
//  Bookwitty
//
//  Created by Marwan  on 3/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation

extension URL {
  var withHTTPS: URL? {
    var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
    components?.scheme = "https"
    return components?.url
  }
}
