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
      transitionLayout(withAnimation: false, shouldMeasureAsync: false)
    }
  }
  var penNameSummary: String? {
    didSet {
      applyTextWithStyling(text: penNameSummary)
    }
  }

  var penNamePictureUrl: String? {
    didSet {
      if let penNamePictureUrl = penNamePictureUrl {
        penNameImageNode.url = URL(string: penNamePictureUrl)
      } else {
        penNameImageNode.url = nil
      }
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
    penNameImageNode.style.preferredSize = imageSize
    penNameImageNode.defaultImage = #imageLiteral(resourceName: "penNamePlaceholder").imageMaskedAndTinted(with: ThemeManager.shared.currentTheme.colorNumber18())

    selectedImageNode.style.preferredSize = downArrowImageSize
    selectedImageNode.image = #imageLiteral(resourceName: "tick")
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

  private func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let centeredImageSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0), child: penNameImageNode)
    centeredImageSpec.style.spacingBefore = internalMargin
    centeredImageSpec.style.spacingAfter = internalMargin

    let centeredNameSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0), child: penNameTextNode)

    let horizontalSpecChildren: [ASLayoutElement] = select
      ? [centeredImageSpec, centeredNameSpec, spacer(flexGrow: 1), selectedImageNode]
      : [centeredImageSpec, centeredNameSpec ]
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .stretch, children:  horizontalSpecChildren)

    let separatorSpaceFromStart = imageSize.width + (internalMargin*2)
    separatorNode.backgroundColor = showsSeparator ? ThemeManager.shared.currentTheme.defaultSeparatorColor() : UIColor.clear
    let separatorHorizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .stretch, children:  [spacer(width: separatorSpaceFromStart), separatorNode])

    let verticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .stretch, children: [spacer(flexGrow: 1),horizontalSpec , spacer(flexGrow: 1), separatorHorizontalSpec])
    
    return verticalSpec
  }
}
