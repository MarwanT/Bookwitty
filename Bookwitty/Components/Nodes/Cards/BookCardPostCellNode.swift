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

  let viewModel: BookCardViewModel

  override init() {
    node = BookCardPostContentNode()
    viewModel = BookCardViewModel()
    super.init()
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class BookCardPostContentNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 100.0, height: 190.0)

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
    setupNode()
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

  func setTopicStatistics(numberOfPosts: Int? = nil, numberOfBooks: Int? = nil, numberOfFollowers: Int? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    if let numberOfPosts = numberOfPosts {
      attrStringBuilder = attrStringBuilder
        .append(text: Strings.posts(number: numberOfPosts), fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    if let numberOfBooks = numberOfBooks {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: Strings.books(number: numberOfBooks), fontDynamicType: .caption2)
      addSeparator = true
    }

    if let numberOfFollowers = numberOfFollowers {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: Strings.followers(number: numberOfFollowers), fontDynamicType: .caption2)
    }

    //Set the string value
    topicStatsNode.attributedText = attrStringBuilder.attributedString
    setNeedsLayout()
  }

  private func setupNode() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.style.preferredSize = imageSize
    imageNode.contentMode = UIViewContentMode.scaleAspectFit
    
    authorNode.maximumNumberOfLines = 1
    formatNode.maximumNumberOfLines = 1
    priceNode.maximumNumberOfLines = 1
    topicStatsNode.maximumNumberOfLines = 1
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
    infoArray.append(ASLayoutSpec.spacer(height: internalMargin))
    if isProduct {
      infoArray.append(formatPriceVerticalSpec)
    } else {
      infoArray.append(topicStatsNode)
    }

    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: 0,
                                         justifyContent: .start,
                                         alignItems: .start,
                                         children: infoArray)

    verticalSpec.style.flexShrink = 1.0
    verticalSpec.style.flexGrow = 1.0

    nodesArray.append(ASLayoutSpec.spacer(width: internalMargin))
    nodesArray.append(verticalSpec)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 0,
                                           justifyContent: .start,
                                           alignItems: .stretch,
                                           children: nodesArray)
    return horizontalSpec
  }
}

//Helpers
extension BookCardPostContentNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: internalMargin,
                        left: internalMargin,
                        bottom: internalMargin,
                        right: internalMargin)
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
