//
//  PageCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 5/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PageCellNode: ASCellNode {
  fileprivate let cellHeight: CGFloat = 200.0
  fileprivate let imageHeight: CGFloat = 180.0

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let titleNode: ASTextNode

  fileprivate var titleTextDynamicFont: FontDynamicType {
    get {
      return FontDynamicType.subheadline
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  private func setupNode() {
    //Set Fixed Cell Height
    style.height = ASDimensionMake(cellHeight)
  }

}

// MARK: - Layout
extension PageCellNode {
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //Set Fixed Image Height
    imageNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: imageHeight)
    return ASLayoutSpec()
  }
}
