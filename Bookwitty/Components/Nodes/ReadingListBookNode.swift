//
//  ReadingListBookNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ReadingListBookNode: ASCellNode {
  var imageSize: CGSize = CGSize(width: 60.0, height: 100.0)
  let imageNode: ASNetworkImageNode

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
      }
    }
  }

  private override init() {
    imageNode = ASNetworkImageNode()
    super.init()
  }

  convenience init(imageNodeSize: CGSize) {
    self.init()
    addSubnode(imageNode)
    imageSize = imageNodeSize
    setupNode()
  }

  private func setupNode() {
    imageNode.imageModificationBlock = { image in
      return image.imageWithSize(size: self.imageSize) ?? image
    }
    imageNode.style.width = ASDimensionMake(imageSize.width)
    imageNode.style.maxHeight = ASDimensionMake(imageSize.height)
    imageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: imageSize)
    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
  }

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageLayoutInset = ASInsetLayoutSpec(insets: imageInset(), child: imageNode)
    imageLayoutInset.style.layoutPosition = CGPoint(x: 0, y: 0)

    return ASAbsoluteLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.default, children: [imageLayoutInset])
  }
}
