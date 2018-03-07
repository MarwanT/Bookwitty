//
//  ArticleCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ArticleCardPostCellNode: BaseCardPostNode {

  let node: ArticleCardContentNode
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: ArticleCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }

  override init() {
    node = ArticleCardContentNode()
    viewModel = ArticleCardViewModel()
    super.init()
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class ArticleCardContentNode: ASDisplayNode {
  private let externalMargin: CGFloat = 0.0
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  
  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode

  var articleTitle: String? {
    didSet {
      if let articleTitle = articleTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      } else {
        titleNode.attributedText = nil
      }

      titleNode.setNeedsLayout()
    }
  }

  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      } else {
        descriptionNode.attributedText = nil
      }

      descriptionNode.setNeedsLayout()
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      } else {
        imageNode.url = nil
      }

      imageNode.setNeedsLayout()
    }
  }

  var hasImage: Bool {
    get {
      return !(imageUrl?.isEmpty ?? true)
    }
  }
  
  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(descriptionNode)
    setupNode()
  }

  private func setupNode() {
    titleNode.maximumNumberOfLines = 3
    descriptionNode.maximumNumberOfLines = 3

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail

    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
  }

  private func titleInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: externalMargin + internalMargin,
                        bottom: 0,
                        right: externalMargin + internalMargin)
  }

  private func descriptionInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: externalMargin + internalMargin,
                        bottom: 0,
                        right: externalMargin + internalMargin)
  }

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  private func spacer(height: CGFloat) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(width: constrainedSize.max.width, height: 190.0)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    let titleInsetLayoutSpec = ASInsetLayoutSpec(insets: titleInset(), child: titleNode)
    let descriptionInsetLayoutSpec = ASInsetLayoutSpec(insets: descriptionInset(), child: descriptionNode)

    let nodesArray: [ASLayoutElement]
    if (hasImage) {
      nodesArray = [imageInsetLayoutSpec, spacer(height: internalMargin), titleInsetLayoutSpec, spacer(height: internalMargin), descriptionInsetLayoutSpec]
    } else {
      nodesArray = [titleInsetLayoutSpec, spacer(height: internalMargin), descriptionInsetLayoutSpec]
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)

    return verticalStack
  }
}


extension ArticleCardPostCellNode: ArticleCardViewModelDelegate {
  func resourceUpdated(viewModel: ArticleCardViewModel) {
    let values = viewModel.values()
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleTitle = values.content.title
    node.articleDescription = values.content.description
    node.imageUrl = values.content.imageUrl
    setWitValue(witted: values.content.wit.is)
    topComment = values.content.topComment
    tags = values.content.tags
    actionInfoValue = values.content.wit.info
    reported = values.reported
  }
}
