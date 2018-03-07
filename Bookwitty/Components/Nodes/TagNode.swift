//
//  TagNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/15.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TagNode: ASCellNode {
  private var titleNode: ASTextNode
  private var backgroundNode: ASDisplayNode

  override init() {
    titleNode = ASTextNode()
    backgroundNode = ASDisplayNode()

    super.init()
    setupNode()
  }

  private func setupNode() {
    automaticallyManagesSubnodes = true

    backgroundNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber9()
    backgroundNode.cornerRadius = 4
    backgroundNode.isLayerBacked = true
  }

  var tag: String? {
    didSet {
      if let tag = tag {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption3)
          .append(text: tag, color: ThemeManager.shared.currentTheme.defaultTextColor())
          .attributedString
      } else {
        titleNode.attributedText = nil
      }
      titleNode.setNeedsLayout()
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let titleInsetLayout = ASInsetLayoutSpec(insets: tagPadding, child: titleNode)
    let backgroundLayout = ASBackgroundLayoutSpec(child: titleInsetLayout, background: backgroundNode)
    let insetLayout = ASInsetLayoutSpec(insets: tagMargin, child: backgroundLayout)
    return insetLayout
  }

  var tagPadding: UIEdgeInsets {
    return UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
  }

  var tagMargin: UIEdgeInsets {
    return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
  }
}
