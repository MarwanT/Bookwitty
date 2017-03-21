//
//  PenNameDisplayNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PenNameDisplayNodeDelegate {
  func didTapOnHeader(sender: PenNameDisplayNode?)
}

class PenNameDisplayNode: ASControlNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let downArrowImageSize: CGSize = CGSize(width: 45, height: 45)

  private let penNameTextNode: ASTextNode
  private let separatorNode: ASDisplayNode
  private let downArrowImageNode: RotatingImageNode

  private var nodeHeight: CGFloat

  var delegate: PenNameDisplayNodeDelegate?
  var penNameSummary: String? {
    didSet {
      applyTextWithStyling(text: penNameSummary)
      setNeedsLayout()
    }
  }

  private override init() {
    penNameTextNode = ASTextNode()
    separatorNode = ASDisplayNode()
    downArrowImageNode = RotatingImageNode(image: #imageLiteral(resourceName: "downArrow"), size: downArrowImageSize)
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

    penNameTextNode.style.minWidth = ASDimensionMake(120)
    penNameTextNode.maximumNumberOfLines = 1
    penNameTextNode.style.flexGrow = 1
    penNameTextNode.style.flexShrink = 1
    
    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    downArrowImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.colorNumber20())

    addTarget(self, action: #selector(didTouchUpInside(_:)), forControlEvents: .touchUpInside)

  }

  func didTouchUpInside(_ sender: PenNameDisplayNode?) {
    delegate?.didTapOnHeader(sender: sender)
  }

  func updateArrowDirection(direction: RotatingImageNode.Direction, animated: Bool = true) {
    downArrowImageNode.updateDirection(direction: direction, animated: animated)
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

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .spaceBetween, alignItems: .stretch, children: [insetSpec, spacer(width: internalMargin), downArrowImageNode])
    let verticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .stretch, children: [spacer(flexGrow: 1), horizontalSpec, spacer(flexGrow: 1), separatorNode])
    
    return verticalSpec
  }
}

