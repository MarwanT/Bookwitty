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
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: TopicCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }

  override init() {
    node = TopicCardPostContentNode()
    viewModel = TopicCardViewModel()
    super.init()
    shouldHandleTopComments = true
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class TopicCardPostContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let imageHeight: CGFloat = 190.0
  private let subImageSize = CGSize(width: 100.0, height: 190.0)

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
      } else {
        titleNode.attributedText = nil
      }

      titleNode.setNeedsLayout()
    }
  }

  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      } else {
        descriptionNode.attributedText = nil
      }

      descriptionNode.setNeedsLayout()
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      } else {
        imageNode.url = nil
      }

      imageNode.setNeedsLayout()
    }
  }

  var subImageUrl: String? {
    didSet {
      if let subImageUrl = subImageUrl {
        subImageNode.url = URL(string: subImageUrl)
      } else {
        subImageNode.url = nil
      }

      subImageNode.setNeedsLayout()
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
    titleNode.maximumNumberOfLines = 4
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail
    topicStatsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()

    subImageNode.style.preferredSize = subImageSize
    subImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    subImageNode.contentMode = .scaleAspectFit
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
    //Add Image Node and space after it

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    let videoNodeLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: subImageNode)
    let imageOverlayLayoutSpec = ASOverlayLayoutSpec.init(child: imageInsetLayoutSpec, overlay: videoNodeLayoutSpec)

    let titleNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: titleNode)
    let topicStatsNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: topicStatsNode)
    let descriptionNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: descriptionNode)

    nodesArray.append(imageOverlayLayoutSpec)

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

//MARK: - TopicCardViewModelDelegate implementation
extension TopicCardPostCellNode: TopicCardViewModelDelegate {
  func resourceUpdated(viewModel: TopicCardViewModel) {
    let values = viewModel.values()
    setup(forFollowingMode: true)
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleTitle = values.content.title
    node.articleDescription = values.content.description
    node.imageUrl = values.content.image.cover
    node.subImageUrl = values.content.image.thumbnail
    node.setTopicStatistics(numberOfPosts: values.content.statistics.posts, numberOfBooks: values.content.statistics.relatedBooks, numberOfFollowers: values.content.statistics.followers)
    setFollowingValue(following: values.content.following)
    setWitValue(witted: values.content.wit.is)
    actionInfoValue = values.content.wit.info
    shouldHandleTopComments = false
    reported = values.reported
  }
}
