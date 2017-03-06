//
//  DisclosureNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DisclosureNode: ASControlNode {
  private let titleTextNode: ASTextNode
  private let imageNode: ASImageNode
  
  override init() {
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    super.init()
  }
}

extension DisclosureNode {
  enum Style {
    case normal
    case highlighted
    
    var fontType: FontDynamicType {
      switch self {
      case .normal:
        return .caption2
      case .highlighted:
        return .footnote
      }
    }
    
    var tintColor: UIColor {
      switch self {
      case .normal:
        return ThemeManager.shared.currentTheme.defaultTextColor()
      case .highlighted:
        return ThemeManager.shared.currentTheme.colorNumber19()
      }
    }
  }
}
