//
//  VideoCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class VideoCardPostCellNode: BaseCardPostNode {

  let node: VideoCardContentNode
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: VideoCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }

  override func updateMode(fullMode: Bool) {
    super.updateMode(fullMode: fullMode)
    node.setupMode(fullViewMode: fullMode)
  }

  override init() {
    node = VideoCardContentNode()
    viewModel = VideoCardViewModel()
    super.init()
    shouldHandleTopComments = true
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

protocol VideoCardContentDelegate {
  func videoViewTouchUpInside(sender: ASImageNode)
}

class VideoCardContentNode: ASDisplayNode {
  private let externalMargin: CGFloat = 0.0
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  private let playIconSize = CGSize(width: 120, height: 120)

  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode
  var playNode: ASImageNode

  var delegate: VideoCardContentDelegate?

  var tappableTitle: Bool = false {
    didSet {
      if tappableTitle {
        titleNode.addTarget(self, action: #selector(videoViewTouchUpInside(_:)), forControlEvents: .touchUpInside)
      } else {
        titleNode.removeTarget(self, action: #selector(videoViewTouchUpInside(_:)), forControlEvents: .touchUpInside)
      }
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

  var videoUrl: URL?

  var hasImage: Bool {
    get {
      return !(imageUrl?.isEmpty ?? true)
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    playNode = ASImageNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(descriptionNode)
    addSubnode(playNode)
    setupNode()
  }

  private func setupNode() {
    setupMode(fullViewMode: false)

    playNode.image = #imageLiteral(resourceName: "play")
    playNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.colorNumber23().withAlphaComponent(0.9))
    playNode.style.preferredSize = playIconSize

    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.addTarget(self, action: #selector(videoViewTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func setupMode(fullViewMode: Bool) {
    titleNode.maximumNumberOfLines = fullViewMode ? 0 : 3
    descriptionNode.maximumNumberOfLines = fullViewMode ? 0 : 3

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail

    setNeedsLayout()
  }

  func videoViewTouchUpInside(_ sender: ASImageNode?) {
    guard let videoUrl = videoUrl else {
      return
    }

    WebViewController.present(url: videoUrl)

    delegate?.videoViewTouchUpInside(sender: imageNode)
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
    let imageSize = CGSize(width: constrainedSize.max.width, height: 210.0)
    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    let videoNodeLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: playNode)
    let overlayLayoutSpec = ASOverlayLayoutSpec.init(child: imageInsetLayoutSpec, overlay: videoNodeLayoutSpec)


    let titleInsetLayoutSpec = ASInsetLayoutSpec(insets: titleInset(), child: titleNode)
    let descriptionInsetLayoutSpec = ASInsetLayoutSpec(insets: descriptionInset(), child: descriptionNode)

    let nodesArray: [ASLayoutElement]
    if (hasImage) {
      nodesArray = [overlayLayoutSpec, spacer(height: internalMargin), titleInsetLayoutSpec, spacer(height: internalMargin), descriptionInsetLayoutSpec]
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

//MARK: - VideoCardViewModelDelegate implementation
extension VideoCardPostCellNode: VideoCardViewModelDelegate {
  func resourceUpdated(viewModel: VideoCardViewModel) {
    let values = viewModel.values()
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleTitle = values.content.title
    node.articleDescription = values.content.description
    node.videoUrl = values.content.properties.url
    node.imageUrl = values.content.properties.thumbnail
    setWitValue(witted: values.content.wit.is)
    actionInfoValue = values.content.wit.info
    topComment = values.content.topComment
    tags = values.content.tags
    reported = values.reported
  }
}
