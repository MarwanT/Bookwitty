//
//  BookNode.swift
//  Bookwitty
//
//  Created by charles on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BookNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 100.0, height: 125.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var formatNode: ASTextNode
  private var priceNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    formatNode = ASTextNode()
    priceNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(authorNode)
    addSubnode(formatNode)
    addSubnode(priceNode)
    setupNode()
  }

  private func setupNode() {
    style.preferredSize = CGSize(width: imageSize.width + 2 * internalMargin, height: imageSize.height + 2 * internalMargin)
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.style.preferredSize = imageSize

    imageNode.url = URL(string: "https://s-media-cache-ak0.pinimg.com/originals/d9/3a/1f/d93a1f03418f95787ce59cd90338ec02.jpg")!
    imageNode.contentMode = UIViewContentMode.scaleAspectFit

    titleNode.maximumNumberOfLines = 3
    authorNode.maximumNumberOfLines = 1
    formatNode.maximumNumberOfLines = 1
    priceNode.maximumNumberOfLines = 1
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []
    nodesArray.append(imageNode)

    var infoArray: [ASLayoutElement] = []
    let titleAuthorVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .start,
                                                    children: [titleNode, authorNode])

    let formatPriceVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .end,
                                                    alignItems: .start,
                                                    children: [formatNode, priceNode])

    infoArray.append(titleAuthorVerticalSpec)
    infoArray.append(spacer(flexGrow: 1.0))
    infoArray.append(formatPriceVerticalSpec)

    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: 0,
                                         justifyContent: .spaceBetween,
                                         alignItems: .start,
                                         children: infoArray)

    verticalSpec.style.flexShrink = 1.0
    verticalSpec.style.flexGrow = 1.0

    nodesArray.append(spacer(width: internalMargin))
    nodesArray.append(verticalSpec)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 0,
                                           justifyContent: .start,
                                           alignItems: .stretch,
                                           children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: edgeInset(), child: horizontalSpec)
    return insetSpec
  }
}

//Helpers
extension BookNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: internalMargin,
                        left: internalMargin,
                        bottom: internalMargin,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
