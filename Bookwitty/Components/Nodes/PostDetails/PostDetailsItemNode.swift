//
//  PostDetailsItemNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol PostDetailsItemNodeDataSource {
  func postDetailsItem(_ postDetailsItem: PostDetailsItemNode, nodeForItemAt index: Int) -> ASDisplayNode
  func postDetailsItemCount(_ postDetailsItem: PostDetailsItemNode) -> Int
}

class PostDetailsItemNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  var nodes: [ASDisplayNode]
  var dataSource: PostDetailsItemNodeDataSource!

  override init() {
    nodes = []
    super.init()
    automaticallyManagesSubnodes = true
    initializeNodes()
  }

  func initializeNodes() {
    style.flexShrink = 1
    style.flexGrow = 1
  }

  func loadNodes() {
    nodes.removeAll(keepingCapacity: false)

    let nodesCount: Int = dataSource.postDetailsItemCount(self)

    for index in 0..<nodesCount {
      let node = dataSource.postDetailsItem(self, nodeForItemAt: index)
      nodes.append(node)
    }
    setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStack = ASStackLayoutSpec.vertical()
    vStack.spacing = 0.0
    vStack.justifyContent = .start
    vStack.alignItems = .stretch
    vStack.children = nodes
    return vStack
  }

  func index(of node: ASDisplayNode) -> Int? {
    for (index, item) in nodes.enumerated() {
      if node === item {
        return index
      }
    }
    return nil
  }
}

protocol PostDetailItemNodeDelegate {
  func postDetailItemNodeButtonTouchUpInside(postDetailItemNode: PostDetailItemNode, button: ASButtonNode)
}

class PostDetailItemNode: ASCellNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  private let largeImageHeight: CGFloat = 120.0
  private let smallImageHeight: CGFloat = 100.0
  private let imageWidth: CGFloat = 90.0

  let imageNode: ASNetworkImageNode
  let headLineNode: ASTextNode
  let subheadLineNode: ASTextNode
  let captionNode: ASTextNode
  let bodyNode: ASTextNode
  let separator: ASDisplayNode
  let button: ASButtonNode

  var delegate: PostDetailItemNodeDelegate?
  var smallImage: Bool = true
  var showsSubheadline: Bool = true
  var showsButton: Bool = false
  var headLine: String? {
    didSet {
      if let headLine = headLine {
        headLineNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.headline).append(text: headLine).attributedString
      } else {
        headLineNode.attributedText = nil
      }
      setNeedsLayout()
    }
  }
  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      } else {
        imageNode.url = nil
      }
    }
  }
  var subheadLine: String? {
    didSet {
      if let subheadLine = subheadLine {
        subheadLineNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.subheadline).append(text: subheadLine).applyParagraphStyling(lineSpacing: 4.0).attributedString
      } else {
        subheadLineNode.attributedText = nil
      }
      setNeedsLayout()
    }
  }
  var caption: String? {
    didSet {
      if let caption = caption {
        captionNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: caption).applyParagraphStyling(lineSpacing: 4.0).attributedString
      } else {
        captionNode.attributedText = nil
      }
      setNeedsLayout()
    }
  }
  var body: String? {
    didSet {
      if let body = body {
        bodyNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body).append(text: body).attributedString
      } else {
        bodyNode.attributedText = nil
      }
      setNeedsLayout()
    }
  }
  var buttonTitle: String? {
    didSet {
      if let buttonTitle = buttonTitle {
        let buttonFont = FontDynamicType.subheadline.font
        let textColor = ThemeManager.shared.currentTheme.colorNumber23()

        button.setTitle(buttonTitle, with: buttonFont, with: textColor, for: .normal)
      } else {
        button.setTitle("", with: nil, with: nil, for: .normal)
      }
      setNeedsLayout()
    }
  }

  private override init() {
    imageNode = ASNetworkImageNode()
    headLineNode = ASTextNode()
    subheadLineNode = ASTextNode()
    captionNode = ASTextNode()
    bodyNode = ASTextNode()
    separator = ASDisplayNode()
    button = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true
  }

  convenience init(smallImage: Bool = true, showsSubheadline: Bool = true, showsButton: Bool = false) {
    self.init()
    self.smallImage = smallImage
    self.showsSubheadline = showsSubheadline
    self.showsButton = showsButton
    initializeNode()
  }

  func initializeNode() {
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
    style.height = ASDimensionAuto

    //Separator Setup
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1.0)
    separator.style.flexGrow = 1

    //Image Setup
    let imageSize = CGSize(width: imageWidth, height: smallImage ? smallImageHeight : largeImageHeight)
    imageNode.style.width = ASDimensionMake(imageSize.width)
    imageNode.style.height = ASDimensionMake(imageSize.height)
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.contentMode = .scaleToFill

    //Body Setup
    bodyNode.maximumNumberOfLines = 7
    //HeadLine Setup
    headLineNode.maximumNumberOfLines = 3
    //subheadLine Setup
    subheadLineNode.maximumNumberOfLines = 2
    //caption Setup
    captionNode.maximumNumberOfLines = 1

    bodyNode.style.flexGrow = 1
    bodyNode.style.flexShrink = 1

    //Button Style-up
    button.style.height = ASDimensionMake(34.0)
    button.style.flexGrow = 1.0
    button.style.flexShrink = 1.0
    button.titleNode.maximumNumberOfLines = 1
    ThemeManager.shared.currentTheme.styleECommercePrimaryButton(button: button)
    //Add tap delegate
    button.addTarget(self, action: #selector(postDetailItemNodeButtonTouchUpInside), forControlEvents: .touchUpInside)
  }

  func postDetailItemNodeButtonTouchUpInside() {
    delegate?.postDetailItemNodeButtonTouchUpInside(postDetailItemNode: self, button: button)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let outerMostVStack = ASStackLayoutSpec.vertical()
    outerMostVStack.spacing = 0
    outerMostVStack.justifyContent = .start
    outerMostVStack.alignItems = .stretch

    let textRightVStack = ASStackLayoutSpec.vertical()
    textRightVStack.spacing = 0.0
    textRightVStack.justifyContent = .start
    textRightVStack.alignItems = .start
    textRightVStack.children = []
    textRightVStack.style.flexShrink = 1
    textRightVStack.style.flexGrow = 1

    textRightVStack.children?.append(headLineNode)
    let shouldAddSubheadline = showsSubheadline && !subheadLine.isEmptyOrNil()
    if shouldAddSubheadline {
      textRightVStack.children?.append(ASLayoutSpec.spacer(height: internalMargin))
      textRightVStack.children?.append(subheadLineNode)
    }

    if !caption.isEmptyOrNil() {
      let topSpacer = shouldAddSubheadline ? ASLayoutSpec.spacer(height: internalMargin/2) : ASLayoutSpec.spacer(height: internalMargin)
      textRightVStack.children?.append(topSpacer)
      textRightVStack.children?.append(captionNode)
    }

    let outerMostHStack = ASStackLayoutSpec.horizontal()
    outerMostHStack.justifyContent = .start
    outerMostHStack.alignItems = .stretch
    outerMostHStack.children = [imageNode, ASLayoutSpec.spacer(width: internalMargin), textRightVStack]

    var outerVStackChildren: [ASLayoutElement] = []
    if !body.isEmptyOrNil() {
      outerVStackChildren.append(outerMostHStack)
      outerVStackChildren.append(ASLayoutSpec.spacer(height: contentSpacing))
      outerVStackChildren.append(bodyNode)
    } else {
       outerVStackChildren.append(outerMostHStack)
    }
    if showsButton {
      let buttonHStack = ASStackLayoutSpec.horizontal()
      buttonHStack.justifyContent = .start
      buttonHStack.alignItems = .stretch
      buttonHStack.children = [button, ASLayoutSpec.spacer(flexGrow: 1)]
      outerVStackChildren.append(ASLayoutSpec.spacer(height: internalMargin))
      outerVStackChildren.append(buttonHStack)
    }

    outerVStackChildren.append(ASLayoutSpec.spacer(height: contentSpacing))
    outerVStackChildren.append(separator)
    outerMostVStack.children = outerVStackChildren
    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: contentSpacing, left: internalMargin, bottom: 0, right: internalMargin), child: outerMostVStack)
  }
}
