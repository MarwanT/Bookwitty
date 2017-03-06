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
  
  var configuration = Configuration() 
  
  override init() {
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    super.init()
    initializeNode()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    style.height = ASDimensionMake(Configuration.nodeHeight)
    imageNode.image = #imageLiteral(resourceName: "rightArrow")
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
  
  struct Configuration {
    static var nodeHeight: CGFloat = 45.0
    var nodeEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
    
    var normalBackgroundColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    var selectedBackgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
    var isAutoDeselectable: Bool = true
    var style: Style = .normal
  }
}
