//
//  Loader.swift
//  Bookwitty
//
//  Created by Marwan  on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import SwiftLoader

extension SwiftLoader {
  static func configure() {
    var config : SwiftLoader.Config = SwiftLoader.Config()
    config.size = 135.0
    config.coverBackgroundColor = UIColor(white: 0.1, alpha: 0.4)
    SwiftLoader.setConfig(config)
  }
}
