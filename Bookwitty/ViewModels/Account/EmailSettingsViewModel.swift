//
//  EmailSettingsViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/01.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class EmailSettingsViewModel {

  enum Sections: Int {
    case Email = 0
  }

  enum Accessory {
    case Disclosure
    case Switch
    case None
  }

  private let sectionTitles: [String]

  init () {
    sectionTitles = [""]
  }
}
