//
//  FilterCellNode.swift
//  Bookwitty
//
//  Created by charles on 5/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FilterCellNode: ASCellNode {
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let defaultColor = ThemeManager.shared.currentTheme.colorNumber19()
  fileprivate let filterImageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let disclosureImageSize: CGSize = CGSize(width: 10, height: 14)

  private let filterImageNode: ASImageNode
  private let textNode: ASTextNode
  private let disclosureImageNode: ASImageNode

  override init() {
    filterImageNode = ASImageNode()
    textNode = ASTextNode()
    disclosureImageNode = ASImageNode()
    super.init()
    addSubnode(filterImageNode)
    addSubnode(textNode)
    addSubnode(disclosureImageNode)
    setupNodes()
  }

  private func setupNodes() {
    filterImageNode.contentMode = UIViewContentMode.scaleAspectFit
    filterImageNode.style.preferredSize = filterImageSize
    filterImageNode.image = #imageLiteral(resourceName: "filter")

    disclosureImageNode.contentMode = UIViewContentMode.scaleAspectFit
    disclosureImageNode.style.preferredSize = disclosureImageSize
    disclosureImageNode.image = #imageLiteral(resourceName: "rightArrow")

    textNode.attributedText = AttributedStringBuilder(fontDynamicType: .callout)
      .append(text: Strings.filter(), color: defaultColor).attributedString

    filterImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(defaultColor)
    disclosureImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(defaultColor)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.height = ASDimensionMake(contentSpacing + filterImageSize.height)

    let leftHorizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                                         spacing: 0,
                                                         justifyContent: .start,
                                                         alignItems: .center,
                                                         children: [filterImageNode, textNode])


    let imageInsetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: contentSpacing), child: disclosureImageNode)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 0,
                                           justifyContent: .spaceBetween,
                                           alignItems: .stretch,
                                           children: [leftHorizontalSpec, imageInsetSpec])

    return horizontalSpec
  }
}
