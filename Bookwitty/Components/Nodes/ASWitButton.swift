//
//  ASWitButton.swift
//  Bookwitty
//
//  Created by Marwan  on 11/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class ASWitButton: ASButtonNode {
  var configuration = Configuration() 
  fileprivate(set) var displayMode: DisplayMode = .lightWeight
}

// MARK: - DISPLAY MODE
                                   //****\\
extension ASWitButton {
  enum DisplayMode {
    case lightWeight
    case heavyWeight
  }
}

// MARK: - CONFIGURATION
                                   //****\\
extension ASWitButton {
  struct Configuration {
    var font = FontDynamicType.subheadline.font
    var height: CGFloat = 45.0
  }
}
