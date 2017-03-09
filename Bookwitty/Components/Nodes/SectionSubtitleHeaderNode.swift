//
//  SectionSubtitleHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class SectionSubtitleHeaderNode: ASCellNode {
  fileprivate let titleNode: ASTextNode
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init() {
    titleNode = ASTextNode()
    super.init()
    initializeComponents()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    style.minHeight = ASDimensionMake(configuration.minimumHeight)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.width = ASDimensionMake(constrainedSize.max.width)
    
    // Layout Forground/Title Node
    let titleInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.titleEdgeInsets,
      child: titleNode)
    let centerTitleVertically = ASCenterLayoutSpec(
      horizontalPosition:
      ASRelativeLayoutSpecPosition.start,
      verticalPosition: ASRelativeLayoutSpecPosition.center,
      sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
      child: titleInsetsSpec)
    let externalInsets = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets, child: centerTitleVertically)
    return externalInsets
  }
  
  var title: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: title ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
}

extension SectionSubtitleHeaderNode {
  struct Configuration {
    var externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: 0, bottom: 0, right: 0)
    fileprivate var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var minimumHeight: CGFloat {
      return 60.0 + externalEdgeInsets.bottom + externalEdgeInsets.top
    }
    fileprivate var titleEdgeInsets = UIEdgeInsets(
      top: 10, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
  }
}
