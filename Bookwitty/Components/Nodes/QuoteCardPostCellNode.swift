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
  private var quoteTextNode: ASTextNode
  private var nameTextNode: ASTextNode
  private var commentsSummaryNode: ASTextNode

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
}
