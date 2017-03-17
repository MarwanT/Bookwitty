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
    config.size = 50.0
    config.loaderSpinnerMarginSide = 13.0
    config.coverBackgroundColor = UIColor(white: 0.4, alpha: 0.4)
    SwiftLoader.setConfig(config)
  }
}
