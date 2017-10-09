//
//  LimitedEditableTextNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/09.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class LimitedEditableTextNode: ASCellNode {
  let textNode: ASEditableTextNode
  let charactersLeftNode: ASTextNode

  override init() {
    textNode = ASEditableTextNode()
    charactersLeftNode = ASTextNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    textNode.style.height = ASDimension(unit: .points, value: 80.0)
    textNode.maximumLinesToDisplay = 3

    textNode.style.flexGrow = 1.0
    textNode.style.flexShrink = 1.0

    charactersLeftNode.style.flexGrow = 1.0
    charactersLeftNode.style.flexShrink = 1.0
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let nodesArray: [ASLayoutElement] = [textNode, charactersLeftNode]
    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 0.0,
                                           justifyContent: .start,
                                           alignItems: .stretch,
                                           children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: externalEdgeInsets(), child: verticalSpec)
    return insetSpec
  }

  private func externalEdgeInsets() -> UIEdgeInsets {
    return UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
