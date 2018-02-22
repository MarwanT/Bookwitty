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
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: QuoteCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }
  
  override init() {
    node = QuoteCardPostContentNode()
    viewModel = QuoteCardViewModel()
    super.init()
    shouldHandleTopComments = true
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }

  override func updateMode(fullMode: Bool) {
    super.updateMode(fullMode: fullMode)
    node.setupMode(fullViewMode: fullMode)
  }
}

class QuoteCardPostContentNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  private var quoteTextNode: ASTextNode
  private var nameTextNode: ASTextNode

  var articleQuote: String? {
    didSet {
      if let articleQuote = articleQuote {
        quoteTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleQuote, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      } else {
        quoteTextNode.attributedText = nil
      }

      quoteTextNode.setNeedsLayout()
    }
  }

  var articleQuotePublisher: String? {
    didSet {
      if let articleQuotePublisher = articleQuotePublisher?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        nameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: articleQuotePublisher, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      } else {
        nameTextNode.attributedText = nil
      }

      nameTextNode.setNeedsLayout()
    }
  }

  override init() {
    quoteTextNode = ASTextNode()
    nameTextNode = ASTextNode()
    super.init()
    addSubnode(quoteTextNode)
    addSubnode(nameTextNode)
    setupNode()
  }

  private func setupNode() {
    setupMode(fullViewMode: false)
  }

  func setupMode(fullViewMode: Bool) {
    quoteTextNode.maximumNumberOfLines = fullViewMode ? 0 : 3
    nameTextNode.maximumNumberOfLines = fullViewMode ? 0 : 1

    quoteTextNode.truncationMode = NSLineBreakMode.byTruncatingTail
    nameTextNode.truncationMode = NSLineBreakMode.byTruncatingTail

    setNeedsLayout()
  }

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let layoutSpecs: [ASLayoutElement] = [quoteTextNode, spacer(height: internalMargin/2), nameTextNode]

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: layoutSpecs)
    return verticalStack
  }
}

//MARK: - QuoteCardViewModelDelegate implementation
extension QuoteCardPostCellNode: QuoteCardViewModelDelegate {
  func resourceUpdated(viewModel: QuoteCardViewModel) {
    let values = viewModel.values()
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleQuotePublisher = values.content.publisher
    if let quote = values.content.quote {
      node.articleQuote = "“ \(quote) ”"
    }
    setWitValue(witted: values.content.wit.is)
    actionInfoValue = values.content.wit.info
    topComment = values.content.topComment
    tags = values.content.tags
    reported = values.reported
  }
}
