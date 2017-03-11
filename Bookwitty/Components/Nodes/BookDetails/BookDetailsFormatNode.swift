//
//  BookDetailsFormatNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsFormatNode: ASCellNode {
  fileprivate let borderNode: ASDisplayNode
  fileprivate let textNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    borderNode = ASDisplayNode()
    textNode = ASTextNode()
    super.init()
    initializeComponents()
    applyTheme()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    textNode.isLayerBacked = true
    borderNode.isLayerBacked = true
    
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let formatTextSpec = ASInsetLayoutSpec(insets: configuration.formatTextEdgeInsets, child: textNode)
    let backgroundSpec = ASBackgroundLayoutSpec(child: formatTextSpec, background: borderNode)
    let externalInsets = ASInsetLayoutSpec(insets: configuration.externalEdgeInsets, child: backgroundSpec)
    return externalInsets
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
    var externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(), bottom: 0,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    fileprivate var formatTextEdgeInsets = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin(),
      ThemeManager.shared.currentTheme.titleMargin())
  }
}

extension BookDetailsFormatNode: Themeable {
  func applyTheme() {
    borderNode.borderWidth = 1.0
    borderNode.borderColor = ThemeManager.shared.currentTheme.colorNumber18().cgColor
  }
}
