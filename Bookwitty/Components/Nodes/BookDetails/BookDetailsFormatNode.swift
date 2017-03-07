//
//  BookDetailsFormatNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsFormatNode: ASCellNode {
  fileprivate let textNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    textNode = ASTextNode()
    super.init()
    initializeComponents()
    applyTheme()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    textNode.isLayerBacked = true
    
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetsSpec = ASInsetLayoutSpec(insets: configuration.viewEdgeInset, child: textNode)
    return insetsSpec
  }
  
  var format: String? {
    didSet {
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: Strings.format() + ": " + (format ?? ""), color: configuration.textColor).attributedString
      setNeedsLayout()
    }
  }
}

extension BookDetailsFormatNode {
  struct Configuration {
    let textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var viewEdgeInset = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin())
  }
}

extension BookDetailsFormatNode: Themeable {
  func applyTheme() {
    borderWidth = 1.0
    borderColor = ThemeManager.shared.currentTheme.colorNumber18().cgColor
  }
}
