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

  override func updateMode(fullMode: Bool) {
    node.setupMode(fullViewMode: fullMode)
  }

  override init() {
    node = VideoCardContentNode()
    super.init()
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

protocol VideoCardContentDelegate {
  func videoImageTouchUpInside(sender: ASImageNode)
}

class VideoCardContentNode: ASDisplayNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  private let playIconSize = CGSize(width: 120, height: 120)

  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode
  var playNode: ASImageNode

  var delegate: VideoCardContentDelegate?

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
  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      }
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
    imageNode.addTarget(self, action: #selector(videoImageTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func setupMode(fullViewMode: Bool) {
    articleTitle = "Ride-hailing company Uber Technologies Inc will launch a standalone meal delivery service app, UberEATS, in select U.S. cities in the coming weeks, a company spokeswoman said. The UberEATS app, already available for over a month in Toronto, Canada, will launch in 10 cities including New York, Los Angeles and Chicago."
    articleDescription = "The company's UberEATS service, a feature within the Uber ride-hailing app, currently provides a limited curated menu, Uber spokeswoman told Reuters. The new app will allow customers to order from other restaurants and the meals will be delivered by Uber drivers. The app will be available on devices that run on Apple Inc's iOS and Alphabet Inc's Android. The move will pit Uber against GrubHub Inc, Postmates Inc and DoorDash Inc in the intensely competitive food delivery business."

    titleNode.maximumNumberOfLines = fullViewMode ? 0 : 3
    descriptionNode.maximumNumberOfLines = fullViewMode ? 0 : 3
    setNeedsLayout()
  }

  func videoImageTouchUpInside(_ sender: ASImageNode?) {
    guard let videoUrl = videoUrl else {
      return
    }

    guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
      return
    }

    WebViewController.present(url: videoUrl, inViewController: rootViewController)

    delegate?.videoImageTouchUpInside(sender: imageNode)
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
    let imageSize = CGSize(width: constrainedSize.max.width, height: 150)
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
