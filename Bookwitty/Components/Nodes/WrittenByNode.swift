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
  private let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
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

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //TODO: layout elements
    return ASStackLayoutSpec.vertical()
  }
}

//MARK" - ButtonWithLoader Delegate Implementation
extension WrittenByNode : ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader) {
      delegate?.writtenByNode(node: self, followButtonTouchUpInside: buttonWithLoader)
  }
}
