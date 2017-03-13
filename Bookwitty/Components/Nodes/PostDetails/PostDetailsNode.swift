//
//  PostDetailsNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import DTCoreText

extension PostDetailsNode: DTAttributedTextContentNodeDelegate {
  func attributedTextContentNodeNeedsLayout(node: DTAttributedTextContentNode) {
    setNeedsLayout()
  }
}

class PostDetailsNode: ASScrollNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let headerNode: PostDetailsHeaderNode
  fileprivate let descriptionNode: DTAttributedTextContentNode//ASTextNode
  fileprivate let postItemsNode: PostDetailsItemNode
  fileprivate let separator: ASDisplayNode
  fileprivate let conculsionNode: ASTextNode
  fileprivate let postItemsNodeLoader: LoaderNode

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
      if let body = body {
        descriptionNode.htmlString(text: body, fontDynamicType: FontDynamicType.body)
      }
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
  var showPostsLoader: Bool = false {
    didSet {
      if isNodeLoaded {
        setNeedsLayout()
      }
    }
  }

  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = DTAttributedTextContentNode()
    postItemsNode = PostDetailsItemNode()
    separator = ASDisplayNode()
    conculsionNode = ASTextNode()
    postItemsNodeLoader = LoaderNode()
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = DTAttributedTextContentNode()
    postItemsNode = PostDetailsItemNode()
    separator = ASDisplayNode()
    conculsionNode = ASTextNode()
    postItemsNodeLoader = LoaderNode()
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
    descriptionNode.delegate = self

    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    separator.style.flexGrow = 1
    separator.style.flexShrink = 1
    separator.style.height = ASDimensionMake(1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    descriptionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 125)
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

    vStackSpec.children = [headerNode, descriptionInsetSpec, separatorInsetSpec]
    postItemsNodeLoader.updateLoaderVisibility(show: showPostsLoader)
    if showPostsLoader {
      let postItemsLoaderOverlaySpec = ASWrapperLayoutSpec(layoutElement: postItemsNodeLoader)
      postItemsLoaderOverlaySpec.style.width = ASDimensionMake(constrainedSize.max.width)
      vStackSpec.children?.append(postItemsLoaderOverlaySpec)
    }
    vStackSpec.children?.append(postItemsNode)


    if !conculsion.isEmptyOrNil() {
      let conculsionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: conculsionNode)
      vStackSpec.children?.append(conculsionInsetSpec)
    }
    return vStackSpec
  }
}
