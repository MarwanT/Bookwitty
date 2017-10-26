//
//  ActionBarNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/24.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class ActionBarNode: ASCellNode {
  let actionButton = ButtonWithLoader()
  let editButton = ASButtonNode()
  let moreButton = ASButtonNode()

  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }

  override init() {
    super.init()
    initializeComponents()
    self.applyTheme()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true

    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()

    editButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    editButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    editButton.style.preferredSize = configuration.iconSize

    moreButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    moreButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    moreButton.style.preferredSize = configuration.iconSize
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let leftNodes: [ASLayoutElement] = [actionButton]
    let leftStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .start, alignItems: .stretch, children: leftNodes)
    leftStackLayoutSpec.style.flexGrow = 1.0

    let rightNodes: [ASLayoutElement] = [editButton, moreButton]
    let rightStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .end, alignItems: .stretch, children: rightNodes)
    rightStackLayoutSpec.style.flexGrow = 1.0

    let toolbarNodes: [ASLayoutElement] = [leftStackLayoutSpec, rightStackLayoutSpec]
    let toolbarStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .center, children: toolbarNodes)
    toolbarStackLayoutSpec.style.flexShrink = 1.0

    let insetLayoutSpec = ASInsetLayoutSpec(insets: configuration.insets, child: toolbarStackLayoutSpec)
    insetLayoutSpec.style.flexGrow = 1.0
    insetLayoutSpec.style.flexShrink = 1.0

    let verticalLayoutSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .stretch, children: [SeparatorNode(), insetLayoutSpec])
    verticalLayoutSpec.style.height = ASDimensionMake(configuration.height)
    verticalLayoutSpec.style.flexShrink = 1.0
    return verticalLayoutSpec
  }
}

extension ActionBarNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    self.styleActionButton()
  }

  fileprivate func styleActionButton() {
    actionButton.style.height = ASDimensionMake(configuration.buttonSize.height)

    let buttonFont = FontDynamicType.subheadline.font
    let buttonColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    actionButton.setupSelectionButton(defaultBackgroundColor: backgroundColor,
                                      selectedBackgroundColor: buttonColor,
                                      borderStroke: true,
                                      borderColor: buttonColor,
                                      borderWidth: 2.0,
                                      cornerRadius: 2.0)

    //TODO: Check if `follow`
    actionButton.setTitle(title: Strings.follow(), with: buttonFont, with: buttonColor, for: .normal)
    actionButton.setTitle(title: Strings.following(), with: buttonFont, with: backgroundColor, for: .selected)

    //TODO: Check if `wit`
    actionButton.style.preferredSize.width = 75.0
    actionButton.setTitle(title: Strings.wit_it(), with: buttonFont, with: buttonColor, for: .normal)
    actionButton.setTitle(title: Strings.witted(), with: buttonFont, with: backgroundColor, for: .selected)
  }
}

extension ActionBarNode {
  struct Configuration {
    var internalSpacing = ThemeManager.shared.currentTheme.contentSpacing() / 4.0
    var insets: UIEdgeInsets {
      return UIEdgeInsets(top: internalSpacing - 1.0, left: 2 * internalSpacing, bottom: internalSpacing - 1.0, right: 2 * internalSpacing)
    }

    var edgeInsets: UIEdgeInsets {
      return UIEdgeInsets(top: 0.0, left: 2 * internalSpacing, bottom: 0.0, right: 2 * internalSpacing)
    }

    var height: CGFloat = 50.0
    var buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
    var iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  }
}
