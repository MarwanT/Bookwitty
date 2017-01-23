//
//  Font.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

enum Font: String {
  case georgia = "GEORGIA_FONT_NAME"
  case ubuntu = "UBUNTU_FONT_NAME"
  case volkhov = "VOLKHOV_FONT_NAME"
  
  func of(style: UIFontTextStyle) -> UIFont {
    let preferred = UIFont.preferredFont(forTextStyle: style).pointSize
    return UIFont(name: self.rawValue, size: preferred)!
  }
}
