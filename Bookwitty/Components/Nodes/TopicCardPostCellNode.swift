//
//  TopicCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class TopicCardPostCellNode: BaseCardPostNode {

  let node: TopicCardPostContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = TopicCardPostContentNode()
    super.init()
  }
}

class TopicCardPostContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let imageHeight: CGFloat = 150.0

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var topicStatsNode: ASTextNode
  private var descriptionNode: ASTextNode


  var articleTitle: String? {
    didSet {
      if let articleTitle = articleTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      }
    }
  }
  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      }
    }
  }
  var articleTopicStats: String? {
    didSet {
      if let articleTopicStats = articleTopicStats {
        topicStatsNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: articleTopicStats, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
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
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(descriptionNode)
    setupNode()
  }

  private func setupNode() {
    titleNode.maximumNumberOfLines = 4
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1
  }

  private func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }

  private func spacer(height: CGFloat) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
    }
  }

  private func cardSidesInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin + externalMargin,
                        bottom: 0 ,
                        right: internalMargin + externalMargin)
  }

}
