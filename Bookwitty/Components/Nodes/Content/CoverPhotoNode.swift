//
//  CoverPhotoNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CoverPhotoNode: ASCellNode {

  let imageNode: ASNetworkImageNode
  let photoButton: ASButtonNode
  let deleteButton: ASButtonNode

  override init() {
    imageNode = ASNetworkImageNode()
    photoButton = ASButtonNode()
    deleteButton = ASButtonNode()
    super.init()
    setupNode()
  }

  private func setupNode() {
    automaticallyManagesSubnodes = true
    imageNode.backgroundColor = UIColor.clear
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue

    photoButton.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    photoButton.clipsToBounds = true
    deleteButton.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    deleteButton.clipsToBounds = true
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageSize = CGSize(width: constrainedSize.max.width, height: 190.0)
    imageNode.style.preferredSize = imageSize

    let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets.zero , child: imageNode)
    imageInsetLayoutSpec.style.flexGrow = 1.0

    let horizontalStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal,
                                                      spacing: 0.0,
                                                      justifyContent: .spaceBetween,
                                                      alignItems: .end,
                                                      children: [photoButton, deleteButton])

    let actionsInsetLayoutSpec = ASInsetLayoutSpec(insets: actionButtonsInset(), child: horizontalStackLayoutSpec)

    let overlayLayoutSpec = ASOverlayLayoutSpec(child: imageInsetLayoutSpec, overlay: actionsInsetLayoutSpec)
    return overlayLayoutSpec
  }

  fileprivate func actionButtonsInset() -> UIEdgeInsets {
    let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
    let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
    return UIEdgeInsets(top: 0.0, left: internalMargin, bottom: contentSpacing, right: internalMargin)
  }
}
