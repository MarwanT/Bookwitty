//
//  PenNameCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PenNameCellNode: ASCellNode {
  private let imageSize: CGSize = CGSize(width: 30, height: 30)
  private let downArrowImageSize: CGSize = CGSize(width: 45, height: 45)
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let penNameTextNode: ASTextNode
  private let penNameImageNode: ASNetworkImageNode
  private let selectedImageNode: ASImageNode
  private let separatorNode: ASDisplayNode

  private var nodeHeight: CGFloat
  private var showsSeparator: Bool = true

  var select: Bool = false {
    didSet {
      transitionLayout(withAnimation: true, shouldMeasureAsync: true)
    }
  }
  var penNameSummary: String? {
    didSet {
      applyTextWithStyling(text: penNameSummary)
    }
  }

  private override init() {
    penNameTextNode = ASTextNode()
    penNameImageNode = ASNetworkImageNode()
    separatorNode = ASDisplayNode()
    selectedImageNode = ASImageNode()
    nodeHeight = 45.0 //Temporary Value
    super.init()
    automaticallyManagesSubnodes = true
  }

  convenience init(withSeparator separator: Bool, withCellHeight cellHeight: CGFloat) {
    self.init()
    showsSeparator = separator
    nodeHeight = cellHeight
    setupNodes()
  }

  private func setupNodes() {
    style.height = ASDimensionMake(nodeHeight)

    penNameTextNode.maximumNumberOfLines = 1

    penNameImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, ASDisplayNodeDefaultPlaceholderColor())
    penNameImageNode.url = URL(string: "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    penNameImageNode.style.preferredSize = imageSize
    penNameImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()

    selectedImageNode.style.preferredSize = downArrowImageSize
    selectedImageNode.image = #imageLiteral(resourceName: "downArrow")
    selectedImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.colorNumber19())

    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.style.flexShrink = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
  }

  private func applyTextWithStyling(text: String?) {
    if let text = text {
      penNameTextNode.attributedText =   AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: text).attributedString
    } else {
      penNameTextNode.attributedText = nil
    }
  }
}
