//
//  ReadingListCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ReadingListCardPostCellNode: BaseCardPostNode {
  let node: ReadingListCardContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = ReadingListCardContentNode()
    super.init()
  }
}

class ReadingListCardContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let postText: String = localizedString(key: "number_of_posts_text", defaultValue: "Posts")
  private let booksText: String = localizedString(key: "number_of_books_text", defaultValue: "Books")
  private let followerText: String = localizedString(key: "number_of_follower_text", defaultValue: "Followers")

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


  override init() {
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(descriptionNode)
    setupNode()
  }

  func setupNode() {
    titleNode.maximumNumberOfLines = 3
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1
  }

  func setTopicStatistics(numberOfPosts: String? = nil, numberOfBooks: String? = nil, numberOfFollowers: String? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    if(isValid(numberOfPosts)) {
      attrStringBuilder = attrStringBuilder
        .append(text: numberOfPosts!)
        .append(text: " " + postText, fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    if(isValid(numberOfBooks)) {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: numberOfBooks!)
        .append(text: " " + booksText, fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    if(isValid(numberOfFollowers)) {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: numberOfFollowers!)
        .append(text: " " + followerText, fontDynamicType: .caption2)
    }

    //Set the string value
    descriptionNode.attributedText = attrStringBuilder.attributedString
  }

  private func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
