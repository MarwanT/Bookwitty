//
//  PostDetailsItemNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PostDetailsItemNode: ASDisplayNode {

}

class PostDetailItemNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  let imageNode: ASNetworkImageNode
  let headLineNode: ASTextNode
  let subheadLineNode: ASTextNode
  let captionNode: ASTextNode
  let bodyNode: ASTextNode
  let separator: ASDisplayNode

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
        bodyNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body).append(text: body).applyParagraphStyling(lineSpacing: 4.0).attributedString
      } else {
        bodyNode.attributedText = nil
      }
      setNeedsLayout()
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    headLineNode = ASTextNode()
    subheadLineNode = ASTextNode()
    captionNode = ASTextNode()
    bodyNode = ASTextNode()
    separator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
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
    imageNode.style.preferredSize = CGSize(width: 90.0, height: 90.0)
    imageNode.backgroundColor = UIColor.bwKeppel
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

    if !headLine.isEmptyOrNil() {
      textRightVStack.children?.append(headLineNode)
      if !subheadLine.isEmptyOrNil() {
        textRightVStack.children?.append(ASLayoutSpec.spacer(height: internalMargin))
        textRightVStack.children?.append(subheadLineNode)
      }
      if !caption.isEmptyOrNil() {
        textRightVStack.children?.append(ASLayoutSpec.spacer(height: internalMargin/2))
        textRightVStack.children?.append(captionNode)
      }
    } else if !subheadLine.isEmptyOrNil() {
      textRightVStack.children?.append(subheadLineNode)
      textRightVStack.children?.append(ASLayoutSpec.spacer(height: internalMargin/2))
      textRightVStack.children?.append(captionNode)
    } else {
      textRightVStack.children?.append(captionNode)
    }

    let outerMostHStack = ASStackLayoutSpec.horizontal()
    outerMostHStack.justifyContent = .start
    outerMostHStack.alignItems = .stretch
    outerMostHStack.children = [imageNode, ASLayoutSpec.spacer(width: internalMargin), textRightVStack]
    if !body.isEmptyOrNil() {
      outerMostVStack.children = [outerMostHStack, ASLayoutSpec.spacer(height: contentSpacing), bodyNode,
                                  ASLayoutSpec.spacer(height: contentSpacing), separator]
    } else {
      outerMostVStack.children = [outerMostHStack, ASLayoutSpec.spacer(height: contentSpacing), separator]
    }
    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: contentSpacing, left: internalMargin, bottom: 0, right: internalMargin), child: outerMostVStack)
  }
}
