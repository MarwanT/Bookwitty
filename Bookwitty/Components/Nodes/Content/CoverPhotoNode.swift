//
//  CoverPhotoNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CoverPhotoNodeDelegate: class {
  func coverPhoto(node: CoverPhotoNode, didRequest action: CoverPhotoNode.Action)
}

class CoverPhotoNode: ASCellNode {

  enum Action {
    case gallery
    case delete
  }

  let imageNode: ASNetworkImageNode
  let photoButton: ASButtonNode
  let deleteButton: ASButtonNode

  weak var delegate: CoverPhotoNodeDelegate?

  var image: UIImage? {
    didSet {
      imageNode.image = image
      imageNode.setNeedsLayout()
    }
  }

  var url: String? {
    didSet {
      imageNode.url = URL(string: url ?? "")
      imageNode.setNeedsLayout()
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    photoButton = ASButtonNode()
    deleteButton = ASButtonNode()
    super.init()
    setupNode()
  }

  private func setupNode() {
    automaticallyManagesSubnodes = true
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue

    photoButton.backgroundColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    photoButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.defaultBackgroundColor())
    photoButton.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    photoButton.cornerRadius = 25.0 / 2.0
    photoButton.imageNode.contentMode = UIViewContentMode.scaleAspectFit
    photoButton.setImage(#imageLiteral(resourceName: "gallery"), for: .normal)
    photoButton.clipsToBounds = true
    photoButton.addTarget(self, action: #selector(photoButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)

    deleteButton.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    deleteButton.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    deleteButton.cornerRadius = deleteButton.style.preferredSize.width / 2.0
    deleteButton.imageNode.contentMode = UIViewContentMode.scaleAspectFit
    deleteButton.clipsToBounds = true
    deleteButton.setImage(#imageLiteral(resourceName: "bin"), for: .normal)
    deleteButton.addTarget(self, action: #selector(deleteButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
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

//MARK: - Actions
extension CoverPhotoNode {
  func photoButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.coverPhoto(node: self, didRequest: .gallery)
  }


  func deleteButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.coverPhoto(node: self, didRequest: .delete)
  }
}
