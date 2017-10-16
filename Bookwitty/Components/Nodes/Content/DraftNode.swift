//
//  DraftNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/16.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DraftNode: ASCellNode {
  fileprivate let titleNode: ASTextNode
  fileprivate let descriptionNode: ASTextNode

  override init() {
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let titleInsetLayoutSpec = ASInsetLayoutSpec(insets: textEdgeInset(), child: titleNode)
    let descriptionInsetLayoutSpec = ASInsetLayoutSpec(insets: textEdgeInset(), child: descriptionNode)
    let separatorNode = SeparatorNode()

    let verticalStackLayoutSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0.0,
                                                    justifyContent: .spaceBetween,
                                                    alignItems: .start,
                                                    children: [titleInsetLayoutSpec, descriptionInsetLayoutSpec, separatorNode])
    
    return verticalStackLayoutSpec
  }
}

extension DraftNode {
  fileprivate func textEdgeInset() -> UIEdgeInsets {
    let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
    return UIEdgeInsets(top: 5.0, left: internalMargin, bottom: 5.0, right: internalMargin)
  }
}
