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

  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = ASTextNode()
    postItemsNode = PostDetailsItemNode()
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = ASTextNode()
    postItemsNode = PostDetailsItemNode()
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

    descriptionNode.style.flexGrow = 1.0
    descriptionNode.style.flexShrink = 1.0
  }

  func sidesEdgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackSpec = ASStackLayoutSpec.vertical()
    vStackSpec.spacing = contentSpacing
    let descriptionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: descriptionNode)
    vStackSpec.children = [headerNode, descriptionInsetSpec, postItemsNode]

    return vStackSpec
  }
}
