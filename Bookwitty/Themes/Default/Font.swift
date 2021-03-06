//
//  Font.swift
//  Bookwitty
//
//  Created by Marwan  on 1/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

enum Font: String {
  case georgiaRegular = "Georgia"
  case ubuntuRegular = "Ubuntu"
  case ubuntuMedium = "Ubuntu-Medium"
  case volkhovRegular = "Volkhov-Regular"
  case volkhovBold = "Volkhov-Bold"
  case volkhovBoldItalic = "Volkhov-BoldItalic"
  
  enum Weight {
    case regular
    case Medium
  }
  
  func of(style: UIFontTextStyle) -> UIFont {
    let preferred = UIFont.preferredFont(forTextStyle: style).pointSize
    return UIFont(name: self.rawValue, size: preferred)!
  }
}
