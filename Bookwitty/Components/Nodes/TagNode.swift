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
      refreshTitleNode()
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let titleInsetLayout = ASInsetLayoutSpec(insets: tagPadding, child: titleNode)
    let backgroundLayout = ASBackgroundLayoutSpec(child: titleInsetLayout, background: backgroundNode)
    let insetLayout = ASInsetLayoutSpec(insets: tagMargin, child: backgroundLayout)
    return insetLayout
  }

  var tagPadding: UIEdgeInsets {
    return UIEdgeInsets(top: 8.0, left: 10.0, bottom: 8.0, right: 10.0)
  }

  var tagMargin: UIEdgeInsets {
    return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
  }
  
  // Change styling on selection
  override func __setSelected(fromUIKit selected: Bool) {
    super.__setSelected(fromUIKit: selected)
    refreshBackgroud()
    refreshTitleNode()
  }
  
  // MARK: - HELPER METHODS
  private func refreshBackgroud() {
    if isSelected {
      backgroundNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber25()
    } else {
      backgroundNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber9()
    }
    setNeedsLayout()
  }
  
  private func refreshTitleNode() {
    if isSelected {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.Reference.type11)
        .append(text: tag ?? "", color: ThemeManager.shared.currentTheme.colorNumber23())
        .attributedString
    } else {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.Reference.type11)
        .append(text: tag ?? "", color: ThemeManager.shared.currentTheme.colorNumber20())
        .attributedString
    }
    setNeedsLayout()
  }
}
