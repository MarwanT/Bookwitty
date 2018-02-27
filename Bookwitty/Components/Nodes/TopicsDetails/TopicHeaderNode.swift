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
  func topicHeader(node: TopicHeaderNode, requestToViewFullDescription description: String?, from descriptionNode: CharacterLimitedTextNode)
  func topicHeader(node: TopicHeaderNode, requestToFollowPenName button: ButtonWithLoader)
}

class TopicHeaderNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
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
  private var followButton: ButtonWithLoader

  var following: Bool = false {
    didSet {
      followButton.state = self.following ? .selected : .normal
    }
  }

  private var disabled: Bool = true {
    didSet {
      followButton.isHidden = disabled
      followButton.isEnabled = !disabled
      setNeedsLayout()
    }
  }

  weak var delegate: TopicHeaderNodeDelegate?

  override init() {
    coverImageNode = ASNetworkImageNode()
    thumbnailImageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    descriptionNode = CharacterLimitedTextNode()
    topicStatsNode = ASTextNode()
    contributorsNode = ContributorsNode()
    followButton = ButtonWithLoader()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  private func setupNode() {
    coverImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    thumbnailImageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()

    descriptionNode.maxCharacter = 140
    descriptionNode.nodeDelegate = self
    descriptionNode.maximumNumberOfLines = 0
    descriptionNode.autoChange = false
    descriptionNode.mode = .collapsed
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()

    followButton.setupSelectionButton(defaultBackgroundColor: ThemeManager.shared.currentTheme.defaultBackgroundColor(),
                                      selectedBackgroundColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderStroke: true,
                                      borderColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderWidth: 2.0,
                                      cornerRadius: 2.0)

    followButton.setTitle(title: Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    followButton.setTitle(title: Strings.following(), with: buttonFont, with: selectedTextColor, for: .selected)
    followButton.state = self.following ? .selected : .normal
    followButton.style.height = ASDimensionMake(buttonSize.height)
    followButton.delegate = self

    titleNode.maximumNumberOfLines = 4
    topicStatsNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    topicStatsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    titleNode.style.flexGrow = 1.0
    titleNode.style.flexShrink = 1.0
    
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

  var topicDesription: String? {
    didSet {
      if let topicDesription = topicDesription {
        descriptionNode.setString(text: topicDesription.components(separatedBy: .newlines).joined(),
                                  fontDynamicType: .body2,
                                  moreFontDynamicType: .footnote,
                                  color: ThemeManager.shared.currentTheme.colorNumber20())
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

    if isValid(topicTitle) {
      let titleHStack = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                               spacing: internalMargin,
                                               justifyContent: .spaceBetween,
                                               alignItems: .stretch,
                                               children: [titleNode, followButton])
      let titleNodeInset = ASInsetLayoutSpec(insets: sideInset(), child: titleHStack)
      nodesArray.append(ASLayoutSpec.spacer(height: internalMargin))
      nodesArray.append(titleNodeInset)
      nodesArray.append(ASLayoutSpec.spacer(height: externalMargin/2))
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
    nodesArray.append(ASLayoutSpec.spacer(height: externalMargin))

    let count = contributorsNode.imagesUrls?.count ?? 0
    let text = contributorsNode.numberOfContributors
    let showContributors = count != 0 || isValid(text)

    if isValid(description) {
      let descriptionNodeSpecInset = ASInsetLayoutSpec(insets: sideInset(), child: descriptionNode)
      nodesArray.append(descriptionNodeSpecInset)
      nodesArray.append(ASLayoutSpec.spacer(height: count != 0 ? externalMargin : externalMargin/2))
    }

    if showContributors {
      contributorsNode.style.width = ASDimensionMake(constrainedSize.max.width)
      contributorsNode.style.height = ASDimensionMake(45.0)
      nodesArray.append(contributorsNode)
      nodesArray.append(ASLayoutSpec.spacer(height: count != 0 ? externalMargin : 0.0))
    }

    //Height is zero since the `ASStackLayoutSpec` will add the internalMargin as spacing between the items
    nodesArray.append(spacer(height: 0.0))
    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0.0,
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

extension TopicHeaderNode: CharacterLimitedTextNodeDelegate {
  func characterLimitedTextNodeDidTap(_ node: CharacterLimitedTextNode) {
    //Did tap on characterLimited text node
    delegate?.topicHeader(node: self, requestToViewFullDescription: description, from: node)
  }
}

//Actions
extension TopicHeaderNode: ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: CallToAction.follow)
      return
    }

    delegate?.topicHeader(node: self, requestToFollowPenName: buttonWithLoader)
  }
}
