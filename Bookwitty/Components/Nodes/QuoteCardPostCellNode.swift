//
//  QuoteCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SwiftLinkPreview

class QuoteCardPostCellNode: BaseCardPostNode {

  let node: QuoteCardPostContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = QuoteCardPostContentNode()
    super.init()
  }
}

class QuoteCardPostContentNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  private var quoteTextNode: ASTextNode
  private var nameTextNode: ASTextNode
  private var commentsSummaryNode: ASTextNode

  var articleCommentsSummary: String? {
    didSet {
      if let articleCommentsSummary = articleCommentsSummary {
        commentsSummaryNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: articleCommentsSummary, color: ThemeManager.shared.currentTheme.colorNumber15()).attributedString
      }
    }
  }
  var articleQuote: String? {
    didSet {
      if let articleQuote = articleQuote {
        quoteTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleQuote, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }
  var articleQuotePublisher: String? {
    didSet {
      if let articleQuotePublisher = articleQuotePublisher {
        nameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: articleQuotePublisher, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }

  override init() {
    quoteTextNode = ASTextNode()
    nameTextNode = ASTextNode()
    commentsSummaryNode = ASTextNode()
    super.init()
    addSubnode(quoteTextNode)
    addSubnode(nameTextNode)
    addSubnode(commentsSummaryNode)
    setupNode()
  }

  private func setupNode() {
    quoteTextNode.maximumNumberOfLines = 3
    nameTextNode.maximumNumberOfLines = 1
  }

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let commentSummaryVerticalStack = ASStackLayoutSpec(direction: .vertical,
                      spacing: 0,
                      justifyContent: .start,
                      alignItems: .stretch,
                      children: articleCommentsSummary.isEmptyOrNil()
                        ? [spacer(height: internalMargin)]
                        : [spacer(height: contentSpacing), commentsSummaryNode, spacer(height: contentSpacing)])

    let layoutSpecs: [ASLayoutElement] = [quoteTextNode, spacer(height: internalMargin/2), nameTextNode,
                                          commentSummaryVerticalStack]

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: layoutSpecs)
    return verticalStack
  }
}
