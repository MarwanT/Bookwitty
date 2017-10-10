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

}
