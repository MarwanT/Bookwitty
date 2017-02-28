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
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let collectionImageSize: CGSize = CGSize(width: 60, height: 100)

  private let postText: String = Strings.posts()
  private let booksText: String = Strings.books()
  private let followerText: String = Strings.followers()

  private let titleNode: ASTextNode
  private let topicStatsNode: ASTextNode
  private let descriptionNode: ASTextNode
  private let customHorizontalList: ReadingListBooksNode

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
  var imageCollection: [String] = [] {
    didSet {
      customHorizontalList.imageCollection = imageCollection
      setNeedsLayout()
    }
  }

  override init() {
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    customHorizontalList = ReadingListBooksNode()
    super.init()
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(descriptionNode)
    addSubnode(customHorizontalList)
    setupNode()
  }

  func setupNode() {
    titleNode.maximumNumberOfLines = 3
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1

    initializeImageCollectionNode()
  }

  func initializeImageCollectionNode() {
    customHorizontalList.imageNodeSize = collectionImageSize
    customHorizontalList.imageCollection = imageCollection
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

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }

  private func cardSidesInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin + externalMargin,
                        bottom: 0 ,
                        right: internalMargin + externalMargin)
  }

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    if imageCollection.count > 0 {
      let customLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: customHorizontalList)
      nodesArray.append(customLayoutSpec)
    }

    let titleNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: titleNode)
    let topicStatsNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: topicStatsNode)
    let descriptionNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: descriptionNode)

    let statsStr = topicStatsNode.attributedText?.string

    if(isValid(articleTitle)) {
      nodesArray.append(spacer(height: internalMargin))
      nodesArray.append(titleNodeInset)
    }
    if(isValid(statsStr)) {
      nodesArray.append(spacer(height: internalMargin/2))
      nodesArray.append(topicStatsNodeInset)
    }
    if(isValid(articleDescription)) {
      let marginHeight = isValid(statsStr) ? internalMargin/2 : internalMargin

      nodesArray.append(spacer(height: marginHeight))
      nodesArray.append(descriptionNodeInset)
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)

    return verticalStack
  }

}
