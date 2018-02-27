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
  func topicHeader(node: TopicHeaderNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
}

class TopicHeaderNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let imageHeight: CGFloat = 200.0
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  fileprivate let thumbnailImageSize = CGSize(width: 100.0, height: 180.0)

  private var coverImageNode: ASNetworkImageNode
  private var thumbnailImageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var descriptionNode: CharacterLimitedTextNode
  private var topicStatsNode: ASTextNode
  private var contributorsNode: ContributorsNode

  weak var delegate: TopicHeaderNodeDelegate?

  override init() {
    coverImageNode = ASNetworkImageNode()
    thumbnailImageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    descriptionNode = CharacterLimitedTextNode()
    topicStatsNode = ASTextNode()
    contributorsNode = ContributorsNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  private func setupNode() {
    coverImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    thumbnailImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()

    titleNode.maximumNumberOfLines = 4
    topicStatsNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    topicStatsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    coverImageNode.delegate = self
    thumbnailImageNode.delegate = self
  }

  var topicTitle: String? {
    didSet {
      if let topicTitle = topicTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title1)
          .append(text: topicTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
        setNeedsLayout()
      }
    }
  }

  var coverImageUrl: String? {
    didSet {
      if let imageUrl = coverImageUrl {
        coverImageNode.url = URL(string: imageUrl)
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

  func setContributorsValues(numberOfContributors: String?, imageUrls: [String]?) {
    contributorsNode.imagesUrls = imageUrls
    contributorsNode.numberOfContributors = numberOfContributors
  }

  func setTopicStatistics(numberOfFollowers: Int? = nil, numberOfPosts: Int? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    if let numberOfFollowers = numberOfFollowers {
      attrStringBuilder = attrStringBuilder
        .append(text: Strings.followers(number: numberOfFollowers), fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    if let numberOfPosts = numberOfPosts {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: Strings.posts(number: numberOfPosts), fontDynamicType: .caption2)
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
    thumbnailImageNode.contentMode = .scaleAspectFit

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

    var statsAndActionNodes: [ASLayoutElement] = []

    if isValid(topicStatsNode.attributedText?.string) {
      statsAndActionNodes.append(topicStatsNode)
      statsAndActionNodes.append(spacer(flexGrow: 1.0))
      statsAndActionNodes.append(spacer(width: internalMargin))
    }

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
  @objc
  fileprivate func imageNodeTouchUpInside(sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      return
    }

    delegate?.topicHeader(node: self, requestToViewImage: image, from: sender)
  }
}

extension TopicHeaderNode: ASNetworkImageNodeDelegate {  
  func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
    imageNode.addTarget(self, action: #selector(imageNodeTouchUpInside(sender:)), forControlEvents: ASControlNodeEvent.touchUpInside)
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
