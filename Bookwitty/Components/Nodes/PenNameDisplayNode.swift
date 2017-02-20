//
//  PenNameDisplayNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PenNameDisplayNode: ASControlNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let downArrowImageSize: CGSize = CGSize(width: 45, height: 45)

  private let penNameTextNode: ASTextNode
  private let separatorNode: ASDisplayNode
  private let downArrowImageNode: ASImageNode

  private var nodeHeight: CGFloat

  var delegate: PenNameDisplayNodeDelegate?
  var shouldExpand: Bool = true {
    didSet {
    }
  }
  var penNameSummary: String? {
    didSet {
      applyTextWithStyling(text: penNameSummary)
    }
  }

  private override init() {
    penNameTextNode = ASTextNode()
    separatorNode = ASDisplayNode()
    downArrowImageNode = ASImageNode()
    nodeHeight = 45.0 // Temporary value
    super.init()
    automaticallyManagesSubnodes = true
  }

  convenience init(withCellHeight cellHeight: CGFloat) {
    self.init()
    nodeHeight = cellHeight
    setupNodes()
  }

  func setupNodes() {
    style.height = ASDimensionMake(nodeHeight)

    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    downArrowImageNode.style.preferredSize = downArrowImageSize
    downArrowImageNode.image = #imageLiteral(resourceName: "downArrow")
    downArrowImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.colorNumber20())

    downArrowImageNode.transform = CATransform3DMakeRotation(shouldExpand ? CGFloat(M_PI) : 0.0, 0.0, 0.0, 1.0)
  }

  private func applyTextWithStyling(text: String?) {
    if let text = text {
      penNameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
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


    let spec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0), child: penNameTextNode)
    let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: 0), child: spec)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [insetSpec, spacer(flexGrow: 1), downArrowImageNode])
    let verticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .stretch, children: [spacer(flexGrow: 1), horizontalSpec, spacer(flexGrow: 1), separatorNode])
    
    return verticalSpec
  }
}

