//
//  BookCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 4/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BookCardPostCellNode: BaseCardPostNode {

  let node: BookCardPostContentNode
  var showsInfoNode: Bool = false
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = BookCardPostContentNode()
    super.init()
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class BookCardPostContentNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 100.0, height: 150.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var formatNode: ASTextNode
  private var priceNode: ASTextNode
  private let topicStatsNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    formatNode = ASTextNode()
    priceNode = ASTextNode()
    topicStatsNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(authorNode)
    addSubnode(formatNode)
    addSubnode(priceNode)
    addSubnode(topicStatsNode)
  }

  var title: String? {
    didSet {
      if let title = title {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .callout)
          .append(text: title, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var author: String? {
    didSet {
      if let author = author {
        authorNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
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
  var isProduct: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }
}
