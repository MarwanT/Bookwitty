//
//  PhotoCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PhotoCardPostCellNode: BaseCardPostNode {
  let node: PhotoCardContentNode
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: PhotoCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }
  
  override init() {
    node = PhotoCardContentNode()
    viewModel = PhotoCardViewModel()
    super.init()
    shouldHandleTopComments = true
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }

  override func updateMode(fullMode: Bool) {
    super.updateMode(fullMode: fullMode)
    node.setupMode(fullViewMode: fullMode)
  }
}

protocol PhotoCardContentNodeDelegate: class {
  func photoCard(node: PhotoCardContentNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
}

class PhotoCardContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  weak var delegate: PhotoCardContentNodeDelegate?

  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode

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
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    setupNode()
  }

  private func setupNode() {
    setupMode(fullViewMode: false)

    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.addTarget(self, action: #selector(photoImageTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func setupMode(fullViewMode: Bool) {  
    titleNode.maximumNumberOfLines = fullViewMode ? 0 : 3
    descriptionNode.maximumNumberOfLines = fullViewMode ? 0 : 3

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail

    setNeedsLayout()
  }

  func photoImageTouchUpInside(_ sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      return
    }

    delegate?.photoCard(node: self, requestToViewImage: image, from: sender)
  }

  private func spacer(height: CGFloat) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
    }
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

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(width: constrainedSize.max.width, height: 190.0)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

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

//MARK: - PhotoCardViewModelDelegate implementation
extension PhotoCardPostCellNode: PhotoCardViewModelDelegate {
  func resourceUpdated(viewModel: PhotoCardViewModel) {
    let values = viewModel.values()
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleTitle = values.content.title
    node.articleDescription = values.content.description
    node.imageUrl = values.content.imageUrl
    articleCommentsSummary = values.content.comments
    setWitValue(witted: values.content.wit.is)
    actionInfoValue = values.content.wit.info
    topComment = values.content.topComment
    tags = values.content.tags
    reported = values.reported
  }
}
