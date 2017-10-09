//
//  EditableTextNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/09.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class EditableTextNode: ASCellNode {
  let textNode: ASEditableTextNode
  let clearButtonNode: ASButtonNode

  override init() {
    textNode = ASEditableTextNode()
    clearButtonNode = ASButtonNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    textNode.style.height = ASDimension(unit: .points, value: 80.0)
    textNode.maximumLinesToDisplay = 2

    textNode.style.flexGrow = 1.0
    textNode.style.flexShrink = 1.0

    clearButtonNode.style.preferredSize = CGSize(width: 25.0, height: 25.0)
    clearButtonNode.imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    clearButtonNode.setImage(#imageLiteral(resourceName: "x"), for: .normal)
  }
}
