//
//  WrittenByNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/26/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class WrittenByNode: ASCellNode {
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
    //TODO: Setup the node
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //TODO: layout elements
    return ASStackLayoutSpec.vertical()
  }
}
