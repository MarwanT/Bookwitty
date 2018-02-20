//
//  OnBoardingCellSectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingCellSectionNode: ASCellNode {
  static let nodeHeight: CGFloat = 45.0

  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let titleTextNode: ASTextNode
  fileprivate let separator: ASDisplayNode

  var text: String? {
    didSet {
      if let text = text {
        titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
          .append(text: text, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }

  override init() {
    titleTextNode = ASTextNode()
    separator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true

    titleTextNode.maximumNumberOfLines = 1

    titleTextNode.truncationMode = NSLineBreakMode.byTruncatingTail

    style.height = ASDimensionMake(OnBoardingCellSectionNode.nodeHeight)

    separator.style.height = ASDimensionMake(1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    separator.style.width = ASDimensionMake(constrainedSize.max.width)

    let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin), child: titleTextNode)
    let centerSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.Y, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumX, child: insetSpec)
    centerSpec.style.height = ASDimensionMake(OnBoardingCellSectionNode.nodeHeight - 1.0)

    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .spaceBetween,
                                   alignItems: .stretch, children: [centerSpec, separator])
    
    return vStack
  }
}
