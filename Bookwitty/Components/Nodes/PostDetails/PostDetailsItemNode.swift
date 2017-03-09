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
      }
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
        subheadLineNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.subheadline).append(text: subheadLine).attributedString
      }
    }
  }
  var caption: String? {
    didSet {
      if let caption = caption {
        captionNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: caption).attributedString
      }
    }
  }
  var body: String? {
    didSet {
      if let body = body {
        bodyNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body).append(text: body).attributedString
      }
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
    initializeNode()
  }

  func initializeNode() {
    //Separator Setup
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)

    //Image Setup
    imageNode.style.preferredSize = CGSize(width: 75.0, height: 75.0)
    //Body Setup
    bodyNode.maximumNumberOfLines = 7
    //HeadLine Setup
    headLineNode.maximumNumberOfLines = 3
    //subheadLine Setup
    subheadLineNode.maximumNumberOfLines = 2
    //caption Setup
    captionNode.maximumNumberOfLines = 1

    bodyNode.style.flexGrow = 1
    headLineNode.style.flexGrow = 1
    subheadLineNode.style.flexGrow = 1
    captionNode.style.flexGrow = 1

    bodyNode.style.flexShrink = 1
    headLineNode.style.flexShrink = 1
    subheadLineNode.style.flexShrink = 1
    captionNode.style.flexShrink = 1
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let outerMostVStack = ASStackLayoutSpec.vertical()
    outerMostVStack.spacing = contentSpacing
    outerMostVStack.justifyContent = .start
    outerMostVStack.alignItems = .stretch

    let outerMostHStack = ASStackLayoutSpec.horizontal()
    outerMostHStack.justifyContent = .center
    outerMostHStack.alignItems = .stretch

    outerMostVStack.children = [outerMostHStack, bodyNode, separator]
    return outerMostVStack
  }
}
