//
//  TopicHeaderNode.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol TopicHeaderNodeDelegate: class {
  func topicHeader(node: TopicHeaderNode, actionButtonTouchUpInside button: ASButtonNode)
}

class TopicHeaderNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let imageHeight: CGFloat = 200.0
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  fileprivate let thumbnailImageSize = CGSize(width: 100.0, height: 100.0)

  private var coverImageNode: ASNetworkImageNode
  private var thumbnailImageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var topicStatsNode: ASTextNode
  private var actionButton: ASButtonNode
  private var contributorsNode: ContributorsNode

  weak var delegate: TopicHeaderNodeDelegate?

  override init() {
    coverImageNode = ASNetworkImageNode()
    thumbnailImageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    actionButton = ASButtonNode()
    contributorsNode = ContributorsNode()
    super.init()
    addSubnode(coverImageNode)
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(actionButton)
    addSubnode(contributorsNode)
    addSubnode(thumbnailImageNode)
    setupNode()
  }

  private func setupNode() {
    coverImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    coverImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    titleNode.maximumNumberOfLines = 4
    topicStatsNode.maximumNumberOfLines = 1

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    actionButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)
    actionButton.isSelected = self.following

    actionButton.setTitle(Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    actionButton.setTitle(Strings.followed(), with: buttonFont, with: selectedTextColor, for: .selected)
    actionButton.cornerRadius = 2
    actionButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    actionButton.borderWidth = 2
    actionButton.clipsToBounds = true
    actionButton.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  var topicTitle: String? {
    didSet {
      if let topicTitle = topicTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: topicTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
        setNeedsLayout()
      }
    }
  }

  var coverImageUrl: String? {
    didSet {
      if let imageUrl = coverImageUrl {
        coverImageNode.url = URL(string: imageUrl)
        thumbnailImageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }

  var thumbnailImageUrl: String? {
    didSet {
      if let thumbnailImageUrl = thumbnailImageUrl {
        thumbnailImageNode.url = URL(string: thumbnailImageUrl)
        setNeedsLayout()
      }
    }
  }

  var following: Bool = false {
    didSet {
      actionButton.isSelected = following
    }
  }

  func setContributorsValues(numberOfContributors: String?, imageUrls: [String]?) {
    contributorsNode.imagesUrls = imageUrls
    contributorsNode.numberOfContributors = numberOfContributors
  }

  func setTopicStatistics(numberOfFollowers: Int? = nil, numberOfPosts: Int? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    //TODO: This should be handled with localization plurals
    if let followersNumber = String(counting: numberOfFollowers) , (numberOfFollowers ?? 0 > 0) {
      let plural = numberOfFollowers ?? 0 > 1
      let str = plural ? Strings.followers() : Strings.follower()
      attrStringBuilder = attrStringBuilder
        .append(text: followersNumber)
        .append(text: " " + str, fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    //TODO: This should be handled with localization plurals
    if let postsNumber = String(counting: numberOfPosts), (numberOfPosts ?? 0 > 0) {
      let plural = numberOfPosts ?? 0 > 1
      let str = plural ? Strings.posts() : Strings.post()
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: postsNumber)
        .append(text: " " + str, fontDynamicType: .caption2)
    }

    //Set the string value
    topicStatsNode.attributedText = attrStringBuilder.attributedString
    setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let imageSize = CGSize(width: constrainedSize.max.width, height: imageHeight)
    coverImageNode.style.preferredSize = imageSize

    thumbnailImageNode.style.preferredSize = thumbnailImageSize

    let imageLayoutSpec = ASStaticLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.sizeToFit, children: [coverImageNode])
    let thumbnailNodeLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY,
                                                     sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY,
                                                     child: thumbnailImageNode)
    let imageOverlayLayoutSpec = ASOverlayLayoutSpec(child: imageLayoutSpec, overlay: thumbnailNodeLayoutSpec)


    nodesArray.append(imageOverlayLayoutSpec)

    let titleNodeInset = ASInsetLayoutSpec(insets: sideInset(), child: titleNode)
    if isValid(topicTitle) {
      nodesArray.append(titleNodeInset)
    }

    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    actionButton.style.height = ASDimensionMake(buttonSize.height)

    var statsAndActionNodes: [ASLayoutElement] = []

    if isValid(topicStatsNode.attributedText?.string) {
      statsAndActionNodes.append(topicStatsNode)
      statsAndActionNodes.append(spacer(flexGrow: 1.0))
      statsAndActionNodes.append(spacer(width: internalMargin))
    }

    statsAndActionNodes.append(actionButton)

    let statsAndActionHorizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 0,
                                                justifyContent: .end,
                                                alignItems: .center,
                                                children: statsAndActionNodes)

    let horizontalSpecInset = ASInsetLayoutSpec(insets: sideInset(), child: statsAndActionHorizontalSpec)
    nodesArray.append(horizontalSpecInset)

    let count = contributorsNode.imagesUrls?.count ?? 0
    let text = contributorsNode.numberOfContributors
    if count != 0 || isValid(text){
      contributorsNode.style.width = ASDimensionMake(constrainedSize.max.width)
      contributorsNode.style.height = ASDimensionMake(45.0)
      nodesArray.append(contributorsNode)
    }

    //Height is zero since the `ASStackLayoutSpec` will add the internalMargin as spacing between the items
    nodesArray.append(spacer(height: 0.0))
    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: internalMargin,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)
    return verticalStack
  }
}

//Actions
extension TopicHeaderNode {
  func actionButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.topicHeader(node: self, actionButtonTouchUpInside: sender)
  }
}

//Helpers
extension TopicHeaderNode {
  fileprivate func sideInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin,
                        bottom: 0,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
