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
  fileprivate let imageSize: CGSize = CGSize(width: 100.0, height: 180.0)

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
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title3)
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

  var price: String? {
    didSet {
      if let price = price {
        priceNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: price, color: ThemeManager.shared.currentTheme.defaultECommerceColor()).attributedString
      }
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }

  private func setupNode() {
    style.preferredSize = CGSize(width: 0.0, height: imageSize.height)
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.style.preferredSize = imageSize
    imageNode.contentMode = UIViewContentMode.scaleAspectFit

    titleNode.maximumNumberOfLines = 3
    authorNode.maximumNumberOfLines = 1
    formatNode.maximumNumberOfLines = 1
    priceNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    authorNode.truncationMode = NSLineBreakMode.byTruncatingTail
    formatNode.truncationMode = NSLineBreakMode.byTruncatingTail
    priceNode.truncationMode = NSLineBreakMode.byTruncatingTail
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let imageSpeck = ASStaticLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.default, children: [imageNode])

    nodesArray.append(imageSpeck)

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
