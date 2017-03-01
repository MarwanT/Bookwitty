//
//  TopicHeaderNode.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicHeaderNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let imageHeight: CGFloat = 200.0

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var topicStatsNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    setupNode()
  }

  private func setupNode() {
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    titleNode.maximumNumberOfLines = 4
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let imageSize = CGSize(width: constrainedSize.max.width, height: imageHeight)
    imageNode.style.preferredSize = imageSize

    nodesArray.append(imageNode)

    let titleNodeInset = ASInsetLayoutSpec(insets: sideInset(), child: titleNode)
    nodesArray.append(titleNodeInset)

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: internalMargin,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)
    return verticalStack
  }
}

//Helpers
extension TopicHeaderNode {
  fileprivate func sideInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin,
                        bottom: 0,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }
}
