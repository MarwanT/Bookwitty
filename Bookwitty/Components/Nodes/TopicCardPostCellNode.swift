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
  private let subImageSize = CGSize(width: 100.0, height: 100.0)
  private let postText: String = localizedString(key: "number_of_posts_text", defaultValue: "Posts")
  private let booksText: String = localizedString(key: "number_of_books_text", defaultValue: "Books")
  private let followerText: String = localizedString(key: "number_of_follower_text", defaultValue: "Followers")

  private var imageNode: ASNetworkImageNode
  private var subImageNode: ASNetworkImageNode
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
  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      }
    }
  }
  var subImageUrl: String? {
    didSet {
      if let subImageUrl = subImageUrl {
        subImageNode.url = URL(string: subImageUrl)
      }
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    subImageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(subImageNode)
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(descriptionNode)
    setupNode()
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

  private func setupNode() {
    titleNode.maximumNumberOfLines = 4
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1

    subImageNode.style.preferredSize = subImageSize
    subImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
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

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let imageSize = CGSize(width: constrainedSize.max.width, height: imageHeight)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    //Add Image Node and space after it

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    let videoNodeLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: subImageNode)
    let imageOverlayLayoutSpec = ASOverlayLayoutSpec.init(child: imageInsetLayoutSpec, overlay: videoNodeLayoutSpec)

    let titleNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: titleNode)
    let topicStatsNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: topicStatsNode)
    let descriptionNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: descriptionNode)

    if(isValid(imageUrl)) {
      nodesArray.append(imageOverlayLayoutSpec)
    }
    if(isValid(articleTitle)) {
      nodesArray.append(spacer(height: internalMargin))
      nodesArray.append(titleNodeInset)
    }
    if(isValid(topicStatsNode.attributedText?.string)) {
      nodesArray.append(spacer(height: internalMargin/2))
      nodesArray.append(topicStatsNodeInset)
    }
    if(isValid(articleDescription)) {
      let spacerHeight = isValid(topicStatsNode.attributedText?.string) ? internalMargin/2 : internalMargin
      
      nodesArray.append(spacer(height: spacerHeight))
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
