//
//  PenNameFollowNode.swift
//  Bookwitty
//
//  Created by charles on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameFollowNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)

  private var imageNode: ASNetworkImageNode
  private var nameNode: ASTextNode
  private var biographyNode: ASTextNode
  private var actionButton: ASButtonNode

  override init() {
    imageNode = ASNetworkImageNode()
    nameNode = ASTextNode()
    biographyNode = ASTextNode()
    actionButton = ASButtonNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(nameNode)
    addSubnode(biographyNode)
    addSubnode(actionButton)
    setupNode()
  }

  var penName: String? {
    didSet {
      if let penName = penName {
        nameNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: penName, color: ThemeManager.shared.currentTheme.defaultButtonColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var biography: String? {
    didSet {
      if let biography = biography {
        biographyNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: biography, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }

  private func setupNode() {
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)

    nameNode.maximumNumberOfLines = 1
    biographyNode.maximumNumberOfLines = 3

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    actionButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    actionButton.setTitle(Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    actionButton.setTitle(Strings.followed(), with: buttonFont, with: selectedTextColor, for: .selected)
    actionButton.cornerRadius = 2
    actionButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    actionButton.borderWidth = 2
    actionButton.clipsToBounds = true

    imageNode.style.preferredSize = imageSize
    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    actionButton.style.height = ASDimensionMake(buttonSize.height)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []
    nodesArray.append(imageNode)
    nodesArray.append(spacer(width: internalMargin))

    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: internalMargin / 3.0,
                                         justifyContent: .start,
                                         alignItems: .start,
                                         children: [nameNode, biographyNode])
    verticalSpec.style.flexShrink = 1.0

    nodesArray.append(verticalSpec)
    nodesArray.append(spacer(width: internalMargin / 2.0))
    nodesArray.append(actionButton)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 0,
                                           justifyContent: .spaceBetween,
                                           alignItems: .start,
                                           children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: edgeInset(), child: horizontalSpec)
    return insetSpec
  }
}


//Helpers
extension PenNameFollowNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: internalMargin,
                        left: internalMargin,
                        bottom: internalMargin,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
