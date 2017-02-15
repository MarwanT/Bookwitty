//
//  LinkCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SwiftLinkPreview

class LinkCardPostCellNode: BaseCardPostNode {
  
  let node: LinkCardPostContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = LinkCardPostContentNode()
    super.init()
  }
}

protocol LinkCardPostContentDelegate {
  func linkImageTouchUpInside(sender: ASImageNode)
}

class LinkCardPostContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  private let playIconSize = CGSize(width: 120, height: 120)

  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode

  var delegate: LinkCardPostContentDelegate?

  var articleTitle: String? {
    didSet {
      if let articleTitle = articleTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      }
    }
  }
  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      }
    }
  }
  var linkUrl: String? {
    didSet {
      if let linkUrl = linkUrl{
        loadImageFromUrl(url: linkUrl)
      }
    }
  }

  private var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      }
    }
  }

  private var hasImage: Bool {
    get {
      return !(imageUrl?.isEmpty ?? true) || !(linkUrl?.isEmpty ?? true)
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

    imageNode.addTarget(self, action: #selector(videoImageTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  private func loadImageFromUrl(url: String) {
    let slp = SwiftLinkPreview()
    slp.preview(url, onSuccess: { [weak self] (response: SwiftLinkPreview.Response) in
      guard let weakSelf = self else { return }

      let image = response[SwiftLinkResponseKey.image] as? String
      if let image = image {
        weakSelf.imageUrl = image
      }
      if weakSelf.articleTitle.isEmptyOrNil() {
        weakSelf.articleTitle = response[SwiftLinkResponseKey.title] as? String
      }
      if weakSelf.articleDescription.isEmptyOrNil() {
        weakSelf.articleDescription = response[SwiftLinkResponseKey.description] as? String
      }
      }, onError: { (error: PreviewError) in
        //TODO: implement action (Retry if needed)
        print(error.description)
    })
  }

  @objc
  private func videoImageTouchUpInside(_ sender: ASImageNode?) {
    delegate?.linkImageTouchUpInside(sender: imageNode)
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
    return UIEdgeInsets(top: 0, left: 0, bottom: internalMargin , right: 0)
  }

  private func spacer(height: CGFloat) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(width: constrainedSize.max.width, height: 150)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)

    let titleInsetLayoutSpec = ASInsetLayoutSpec(insets: titleInset(), child: titleNode)
    let descriptionInsetLayoutSpec = ASInsetLayoutSpec(insets: descriptionInset(), child: descriptionNode)

    //TODO: Clean adding logic, move top and bottom seraptors from insets to spacers between elements
    let nodesArray: [ASLayoutElement]
    if (hasImage) {
      nodesArray = [imageInsetLayoutSpec, titleInsetLayoutSpec, spacer(height: internalMargin), descriptionInsetLayoutSpec]
    } else {
      if (!articleTitle.isEmptyOrNil() && !articleDescription.isEmptyOrNil()) {
        nodesArray = [titleInsetLayoutSpec, spacer(height: internalMargin), descriptionInsetLayoutSpec]
      } else if (!articleTitle.isEmptyOrNil()) {
        nodesArray = [titleInsetLayoutSpec]
      } else if (!articleDescription.isEmptyOrNil()) {
        nodesArray = [descriptionInsetLayoutSpec]
      } else {
        //Everything was null: Should Never be here
        nodesArray = [spacer(height: internalMargin)]
      }
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)
    
    return verticalStack
  }
}
