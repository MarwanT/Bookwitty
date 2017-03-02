//
//  TopicHeaderNode.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicHeaderNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let imageHeight: CGFloat = 200.0
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  fileprivate let normal = ASControlState(rawValue: 0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var topicStatsNode: ASTextNode
  private var actionButton: ASButtonNode
  private var contributorsNode: ContributorsNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    actionButton = ASButtonNode()
    contributorsNode = ContributorsNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(actionButton)
    addSubnode(contributorsNode)
    setupNode()
  }

  private func setupNode() {
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    titleNode.maximumNumberOfLines = 4
    topicStatsNode.maximumNumberOfLines = 1

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.setBackgroundImage(buttonBackgroundImage, for: normal)
    actionButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    actionButton.setTitle(Strings.follow(), with: buttonFont, with: textColor, for: normal)
    actionButton.setTitle(Strings.followed(), with: buttonFont, with: selectedTextColor, for: .selected)
    actionButton.cornerRadius = 2
    actionButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    actionButton.borderWidth = 2
    actionButton.clipsToBounds = true
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

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }

  var contributorsValues: (imageUrls: [String]?, numberOfContributors: String?)? {
    didSet {
      contributorsNode.imagesUrls = contributorsValues?.imageUrls
      contributorsNode.numberOfContributors = contributorsValues?.numberOfContributors
    }
  }

  func setTopicStatistics(numberOfFollowers: String? = nil, numberOfPosts: String? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    //TODO: This should be handled with localization plurals
    if isValid(numberOfFollowers) {
      attrStringBuilder = attrStringBuilder
        .append(text: numberOfFollowers!)
        .append(text: " " + Strings.followers(), fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    //TODO: This should be handled with localization plurals
    if isValid(numberOfPosts) {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: numberOfPosts!)
        .append(text: " " + Strings.posts(), fontDynamicType: .caption2)
    }

    //Set the string value
    topicStatsNode.attributedText = attrStringBuilder.attributedString
    setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let imageSize = CGSize(width: constrainedSize.max.width, height: imageHeight)
    imageNode.style.preferredSize = imageSize

    if isValid(imageUrl) {
      nodesArray.append(imageNode)
    }

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

    if let contributorsValues = contributorsValues {
      let count = contributorsValues.imageUrls?.count ?? 0
      let text = contributorsValues.numberOfContributors
      if count != 0 || isValid(text){
        contributorsNode.style.width = ASDimensionMake(constrainedSize.max.width)
        contributorsNode.style.height = ASDimensionMake(45.0)
        nodesArray.append(contributorsNode)
      }
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: internalMargin,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)
    return verticalStack
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
