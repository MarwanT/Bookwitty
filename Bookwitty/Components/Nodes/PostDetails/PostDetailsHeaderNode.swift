//
//  PostDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PostDetailsHeaderNodeDelegate: class {
  func postDetailsHeader(node: PostDetailsHeaderNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
  func postDetailsHeader(node: PostDetailsHeaderNode, didRequestActionInfo fromNode: ASTextNode)
}


class PostDetailsHeaderNode: ASCellNode {
  private let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASTextNode
  let profileBarNode: CompactPenNameNode
  fileprivate let actionInfoNode: ASTextNode
  fileprivate let separator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode

  var delegate: PostDetailsHeaderNodeDelegate?

  var title: String? {
    didSet {
      textNode.attributedText = title.isEmptyOrNil() ? nil : AttributedStringBuilder(fontDynamicType: FontDynamicType.title1).append(text: title!).attributedString
    }
  }
  var image: String? {
    didSet {
      imageNode.url = image.isEmptyOrNil() ? nil : URL(string: image!)
    }
  }
  var date: String? {
    didSet {
      profileBarNode.date = date
    }
  }
  var penName: PenName? {
    didSet {
      profileBarNode.penName = penName?.name
      profileBarNode.imageUrl = penName?.avatarUrl
    }
  }

  var actionInfoValue: String? {
    didSet {
      if let actionInfoValue = actionInfoValue {
        actionInfoNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: actionInfoValue, color: ThemeManager.shared.currentTheme.colorNumber15()).attributedString
      } else {
        actionInfoNode.attributedText = nil
      }

      actionInfoNode.setNeedsLayout()
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASTextNode()
    profileBarNode = CompactPenNameNode()
    actionInfoNode = ASTextNode()
    separator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  override func didLoad() {
    imageNode.contentMode = .scaleAspectFill
    imageNode.delegate = self

    actionInfoNode.addTarget(self, action: #selector(actionInfoNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func initializeNode() {
    //Separator Styling
    separator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bottomSeparator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    bottomSeparator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    //Post Iamge
    imageNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 250.0)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.animatedImagePaused = true
    //Post Title
    textNode.style.flexGrow = 1
    textNode.style.flexShrink = 1

  }
  
  func sidesEdgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackSpec = ASStackLayoutSpec.vertical()
    vStackSpec.spacing = 0.0

    let textInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: textNode)
    let bottomSeparatorInset =  ASInsetLayoutSpec(insets: sidesEdgeInset(), child: bottomSeparator)

    let vStackActionBarSpec = ASStackLayoutSpec.vertical()
    var actionNodes: [ASLayoutElement] = []

    if shouldShowActionInfoNode {
      var insets = sidesEdgeInset()
      insets.bottom = externalMargin/2.0
      let actionInfoInset =  ASInsetLayoutSpec(insets: insets, child: actionInfoNode)
      actionNodes.append(actionInfoInset)
      actionNodes.append(bottomSeparatorInset)
    }

    vStackActionBarSpec.children = actionNodes

    var nodesArray: [ASLayoutElement]

    if penName?.id == nil {
      nodesArray = [imageNode, ASLayoutSpec.spacer(height: contentSpacing),
                    textInsetSpec, ASLayoutSpec.spacer(height: contentSpacing)]
    } else {
      nodesArray = [imageNode, ASLayoutSpec.spacer(height: contentSpacing),
                    textInsetSpec, profileBarNode]
    }

    if actionNodes.count > 0 {
      nodesArray.append(vStackActionBarSpec)
    }

    vStackSpec.children = nodesArray
    return vStackSpec
  }

  internal var shouldShowActionInfoNode: Bool {
    return self.actionInfoValue != nil
  }
}

//MARK: - Actions
extension PostDetailsHeaderNode {
  @objc
  fileprivate func actionInfoNodeTouchUpInside(_ sender: ASTextNode) {
    delegate?.postDetailsHeader(node: self, didRequestActionInfo: sender)
  }
}

extension PostDetailsHeaderNode: ASNetworkImageNodeDelegate {
  @objc
  fileprivate func imageNodeTouchUpInside(sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      return
    }

    delegate?.postDetailsHeader(node: self, requestToViewImage: image, from: sender)
  }

  func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
    imageNode.addTarget(self, action: #selector(imageNodeTouchUpInside(sender:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }
}
