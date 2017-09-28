//
//  RichContentBookNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/28.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RichContentBookNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 60.0, height: 90.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var addButton: ASButtonNode
  private var separatorNode: ASDisplayNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    addButton = ASButtonNode()
    separatorNode = ASDisplayNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    style.preferredSize = CGSize(width: 0.0, height: imageSize.height + (internalMargin * 2))
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.style.preferredSize = imageSize
    imageNode.contentMode = UIViewContentMode.scaleAspectFit

    titleNode.maximumNumberOfLines = 4
    authorNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    authorNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    addButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    addButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    addButton.setTitle(Strings.add(), with: buttonFont, with: textColor, for: .normal)

    addButton.titleNode.maximumNumberOfLines = 1
    addButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    addButton.style.height = ASDimensionMake(36.0)
    addButton.style.minWidth = ASDimension(unit: .points, value: 50.0)

    addButton.cornerRadius = 2.0
    addButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    addButton.borderWidth = 2
    addButton.clipsToBounds = true

    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.style.flexShrink = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
  }
}

//Helpers
extension RichContentBookNode {
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
