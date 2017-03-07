//
//  DetailsInfoCellNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DetailsInfoCellNode: ASCellNode {
  fileprivate var keyTextNode: ASTextNode
  fileprivate var valueTextNode: ASTextNode
  
  private var configuration = Configuration()
  
  override init() {
    keyTextNode = ASTextNode()
    valueTextNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    style.minHeight = ASDimensionMake(Configuration.minimumHeight)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    valueTextNode.style.flexShrink = 1.0
    
    let keyNodeInsets = ASInsetLayoutSpec(
      insets: configuration.keyNodeEdgeInsets,
      child: keyTextNode)
    
    let layoutElements: [ASLayoutElement] = [
      keyNodeInsets,
      spacer(flexGrow: 1.0),
      valueTextNode
    ]
    
    let horizontalStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: .start, alignItems: .center, children: layoutElements)
    horizontalStack.style.width = ASDimensionMake(constrainedSize.max.width)
    let stackInsets = ASInsetLayoutSpec(
      insets: configuration.stackEdgeInsets,
      child: horizontalStack)
    
    return stackInsets
  }
  
  private func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
      style.flexShrink = flexGrow
    }
  }
}

extension DetailsInfoCellNode {
  struct Configuration {
    static let minimumHeight: CGFloat = 45
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    let stackEdgeInsets = UIEdgeInsets(
      top: 10, left: 0, bottom: 10,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    let keyNodeEdgeInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: 0,
      right: (ThemeManager.shared.currentTheme.generalExternalMargin() * 2))
  }
}
