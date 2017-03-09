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

  var title: String? {
    didSet {
      if let title = title {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: title, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var author: String? {
    didSet {
      if let author = author {
        authorNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
          .append(text: author, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var format: String? {
    didSet {
      if let format = format {
        formatNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: format, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var price: Double? {
    didSet {
      if let price = price {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let priceString = formatter.string(from: NSNumber(value: price)) ?? String(price)
        priceNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: priceString, color: ThemeManager.shared.currentTheme.defaultECommerceColor()).attributedString
      }
    }
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

    var topNodes: [ASLayoutElement] = []
    if isValid(title) {
      topNodes.append(titleNode)
    }

    if isValid(author) {
      topNodes.append(authorNode)
    }

    let titleAuthorVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .start,
                                                    children: topNodes)

    var bottomNodes: [ASLayoutElement] = []
    if isValid(format) {
      bottomNodes.append(formatNode)
    }

    if isValid(price?.description) {
      bottomNodes.append(priceNode)
    }
    let formatPriceVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .end,
                                                    alignItems: .start,
                                                    children: bottomNodes)

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
