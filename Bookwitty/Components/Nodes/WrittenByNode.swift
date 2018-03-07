//
//  WrittenByNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/26/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol WrittenByNodeDelegate: class {
  func writtenByNode(node: WrittenByNode, followButtonTouchUpInside button: ButtonWithLoader)
}

class WrittenByNode: ASCellNode {
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  fileprivate let userProfileImageDimension: CGFloat = 45.0
  let titleNode: ASTextNode
  let titleSeparatorNode: ASDisplayNode
  let headerNode: CardPostInfoNode
  let biographyNode: ASTextNode
  let followButton: ButtonWithLoader

  var biography: String? {
    didSet {
      if let biography = biography {
        biographyNode.attributedText = AttributedStringBuilder(fontDynamicType: .body3)
          .append(text: biography, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var following: Bool = false {
    didSet {
      followButton.state = self.following ? .selected : .normal
    }
  }

  var postInfoData: CardPostInfoNodeData? {
    didSet {
      headerNode.data = postInfoData
      setNeedsLayout()
    }
  }

  weak var delegate: WrittenByNodeDelegate?

  override init() {
    titleNode = ASTextNode()
    titleSeparatorNode = ASDisplayNode()
    headerNode = CardPostInfoNode()
    biographyNode = ASTextNode()
    followButton = ButtonWithLoader()
    super.init()
    automaticallyManagesSubnodes = true
    setup()
  }

  private func setup() {
    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()

    followButton.setupSelectionButton(defaultBackgroundColor: ThemeManager.shared.currentTheme.defaultBackgroundColor(),
                                      selectedBackgroundColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderStroke: true,
                                      borderColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderWidth: 2.0,
                                      cornerRadius: 2.0)

    followButton.setTitle(title: Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    followButton.setTitle(title: Strings.following(), with: buttonFont, with: selectedTextColor, for: .selected)
    followButton.state = self.following ? .selected : .normal
    followButton.style.height = ASDimensionMake(buttonSize.height)
    followButton.delegate = self

    titleSeparatorNode.style.height = ASDimensionMake(1)
    titleSeparatorNode.style.flexGrow = 1
    titleSeparatorNode.isLayerBacked = true
    titleSeparatorNode.backgroundColor  = ThemeManager.shared.currentTheme.colorNumber18()

    titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .callout)
      .append(text: Strings.written_by(), color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //TOP
    let topVStack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 0.0,
                                      justifyContent: .start,
                                      alignItems: .stretch,
                                      children: [titleNode])
    let topVStackInset = ASInsetLayoutSpec(insets: topStackInset(), child: topVStack)

    //BOTOM
    let bottomVStaskChildren: [ASLayoutElement] = biography.isEmptyOrNil() ? [followButton] : [biographyNode, followButton]
    let bottomVStack = ASStackLayoutSpec(direction: .vertical,
                                         spacing: contentSpacing,
                                         justifyContent: .start,
                                         alignItems: .stretch,
                                         children: bottomVStaskChildren)
    let bottomVStackInset = ASInsetLayoutSpec(insets: bottomStackInset(),
                                              child: bottomVStack)

    //OUTTER SHELL
    let outerVStaskChildren: [ASLayoutElement] = [topVStackInset,
                                                   ASLayoutSpec.spacer(height: externalMargin),
                                                   titleSeparatorNode,
                                                   ASLayoutSpec.spacer(height: externalMargin/2),
                                                   headerNode,
                                                   bottomVStackInset]
    let outerVStack = ASStackLayoutSpec(direction: .vertical,
                                         spacing: 0.0,
                                         justifyContent: .start,
                                         alignItems: .stretch,
                                         children: outerVStaskChildren)

    return ASInsetLayoutSpec(insets: outerStackInset(),
                             child: outerVStack)
  }
}

//MARK: - ButtonWithLoader Delegate Implementation
extension WrittenByNode : ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader) {
    delegate?.writtenByNode(node: self, followButtonTouchUpInside: buttonWithLoader)
  }
}

//MARK: - Helper Functions
extension WrittenByNode {
  fileprivate func topStackInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0.0, left: internalMargin,
                        bottom: 0.0, right: internalMargin)
  }

  fileprivate func bottomStackInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0.0,
                        left: internalMargin + userProfileImageDimension + externalMargin,
                        bottom: 0.0,
                        right: internalMargin)
  }

  fileprivate func outerStackInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0,
                        right: 0.0)
  }
}
