//
//  PostDetailsNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PostDetailsNode: ASScrollNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let headerNode: PostDetailsHeaderNode
  fileprivate let descriptionNode: ASTextNode
  fileprivate let postItemsNode: PostDetailsItemNode
  fileprivate let separator: ASDisplayNode
  fileprivate let conculsionNode: ASTextNode

  var title: String? {
    didSet {
      headerNode.title = title
    }
  }
  var coverImage: String? {
    didSet {
        headerNode.image = coverImage
    }
  }
  var body: String? {
    didSet {
      let attributed = body.isEmptyOrNil() ? nil : AttributedStringBuilder(fontDynamicType: FontDynamicType.title3).append(text: body!, fromHtml: true).attributedString
      descriptionNode.attributedText = attributed
    }
  }
  var date: String? {
    didSet {
      headerNode.date = date
    }
  }
  var penName: PenName? {
    didSet {
      headerNode.penName = penName
    }
  }
  var dataSource: PostDetailsItemNodeDataSource! {
    didSet {
      postItemsNode.dataSource = dataSource
    }
  }
  var conculsion: String? {
    didSet {
      if let conculsion = conculsion {
        conculsionNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body).append(text: conculsion, fromHtml: true).attributedString
      } else {
        conculsionNode.attributedText = nil
      }
    }
  }

  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = ASTextNode()
    postItemsNode = PostDetailsItemNode()
    separator = ASDisplayNode()
    conculsionNode = ASTextNode()
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = ASTextNode()
    postItemsNode = PostDetailsItemNode()
    separator = ASDisplayNode()
    conculsionNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    automaticallyManagesContentSize = true
    initializeNode()
  }

  func loadPostItemsNode() {
    postItemsNode.loadNodes()
    setNeedsLayout()
  }

  func initializeNode() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    separator.style.flexGrow = 1
    separator.style.flexShrink = 1
    separator.style.height = ASDimensionMake(1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    descriptionNode.style.flexGrow = 1.0
    descriptionNode.style.flexShrink = 1.0

    conculsionNode.style.flexGrow = 1.0
    conculsionNode.style.flexShrink = 1.0
  }

  func sidesEdgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackSpec = ASStackLayoutSpec.vertical()
    vStackSpec.spacing = contentSpacing
    let descriptionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: descriptionNode)
    let separatorInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: separator)
    vStackSpec.children = [headerNode, descriptionInsetSpec, separatorInsetSpec, postItemsNode]

    if !conculsion.isEmptyOrNil() {
      let conculsionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: conculsionNode)
      vStackSpec.children?.append(conculsionInsetSpec)
    }
    return vStackSpec
  }
}
