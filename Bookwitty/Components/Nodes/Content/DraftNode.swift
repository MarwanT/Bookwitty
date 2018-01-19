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
  
  fileprivate var configuration = Configuration()

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
          text = AttributedStringBuilder(fontDynamicType: .footnote)
            .append(text: Strings.untitled())
            .attributedString
        } else {
          text = AttributedStringBuilder(fontDynamicType: .footnote)
            .append(text: title)
            .attributedString
        }
      }
      titleNode.attributedText = text
      setNeedsLayout()
    }
  }

  var updatedAt: NSDate? {
    didSet {
      var text: NSAttributedString? = nil
      if let updatedAt = updatedAt {
        let lastEditedString = Strings.last_edited() + " " 
        text = AttributedStringBuilder(fontDynamicType: .caption3)
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
    titleNode.maximumNumberOfLines = 1
    style.height = ASDimensionMake(43)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let descriptionInsetLayoutSpec = ASInsetLayoutSpec(insets: configuration.descriptionEdgeInset, child: descriptionNode)

    let verticalStackLayoutSpec = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.0,
      justifyContent: .center,
      alignItems: .stretch,
      children: [titleNode, descriptionInsetLayoutSpec])
    verticalStackLayoutSpec.style.flexShrink = 1.0
    
    let layoutSpec = ASInsetLayoutSpec(insets: configuration.layoutMargins, child: verticalStackLayoutSpec)

    return layoutSpec
  }
}

extension DraftNode {
  fileprivate struct Configuration {
    var descriptionEdgeInset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
    var layoutMargins = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.cardInternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.cardInternalMargin())
  }
}
