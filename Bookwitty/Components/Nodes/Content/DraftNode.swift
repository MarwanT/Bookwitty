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

  var title: String? {
    didSet {
      var text: NSAttributedString? = nil
      if let title = title {
        if title.isEmpty {
          text = AttributedStringBuilder(fontDynamicType: .subheadline)
            .append(text: "Untitled")
            .attributedString
        } else {
          text = AttributedStringBuilder(fontDynamicType: .subheadline)
            .append(text: title)
            .attributedString
        }
      }
      titleNode.attributedText = text
      titleNode.setNeedsLayout()
    }
  }

  var updatedAt: NSDate? {
    didSet {
      var text: NSAttributedString? = nil
      if let updatedAt = updatedAt {
        let lastEditedString = Strings.last_edited() + " " 
        text = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: lastEditedString, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
          .append(text: updatedAt.formatted(format: "MMM.dd"), color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
          .attributedString
      }
      descriptionNode.attributedText = text
      descriptionNode.setNeedsLayout()
    }
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

    verticalStackLayoutSpec.style.flexShrink = 1.0

    return verticalStackLayoutSpec
  }
}

extension DraftNode {
  fileprivate func textEdgeInset() -> UIEdgeInsets {
    let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
    return UIEdgeInsets(top: 5.0, left: internalMargin, bottom: 5.0, right: internalMargin)
  }
}
