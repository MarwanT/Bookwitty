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
  let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

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

  var hasComments: Bool {
    get {
      return !(articleCommentsSummary?.isEmpty ?? true)
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

  private func commentsSummaryInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: contentSpacing,
                        left: externalMargin + internalMargin,
                        bottom: contentSpacing,
                        right: externalMargin + internalMargin)
  }

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  private func spacer(height: CGFloat) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(width: constrainedSize.max.width, height: 150)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    let commentsSummaryInsetLayoutSpec = ASInsetLayoutSpec(insets: commentsSummaryInset(), child: commentsSummaryNode)

    let nodesArray: [ASLayoutElement]
    if (hasComments) {
      nodesArray = [imageInsetLayoutSpec, commentsSummaryInsetLayoutSpec]
    } else {
      nodesArray = [imageInsetLayoutSpec, spacer(height: internalMargin)]
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)

    return verticalStack
  }
}
