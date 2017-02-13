//
//  PhotoCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PhotoCardPostCellNode: BaseCardPostNode {
  let node: PhotoCardContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = PhotoCardContentNode()
    super.init()
  }
}

class PhotoCardContentNode: ASDisplayNode {
  var imageNode: ASNetworkImageNode
  var commentsSummaryNode: ASTextNode
  
  var articleCommentsSummary: String? {
    didSet {
      if let articleCommentsSummary = articleCommentsSummary {
        commentsSummaryNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: articleCommentsSummary, color: ThemeManager.shared.currentTheme.colorNumber15()).attributedString
      }
    }
  }
  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      }
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    commentsSummaryNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(commentsSummaryNode)
    setupNode()
  }

  private func setupNode() {
    commentsSummaryNode.maximumNumberOfLines = 1
  }

}
