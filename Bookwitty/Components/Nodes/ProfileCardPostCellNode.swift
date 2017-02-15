//
//  ProfileCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ProfileCardPostCellNode: BaseCardPostNode {

  let node: ProfileCardPostContentNode
  override var shouldShowInfoNode: Bool { return false }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = ProfileCardPostContentNode()
    super.init()
  }
}

class ProfileCardPostContentNode: ASDisplayNode {
  private let profileImageSize: CGSize = CGSize(width: 70.0, height: 70.0)

  var userProfileImageNode: ASNetworkImageNode
  var userNameTextNode: ASTextNode
  var followersTextNode: ASTextNode

  override init() {
    userProfileImageNode = ASNetworkImageNode()
    userNameTextNode = ASTextNode()
    followersTextNode = ASTextNode()
    super.init()
    addSubnode(userProfileImageNode)
    addSubnode(userNameTextNode)
    addSubnode(followersTextNode)
    setupNodes()
  }

  func setupNodes() {
    userNameTextNode.maximumNumberOfLines = 1
    followersTextNode.maximumNumberOfLines = 1

    let profileBorderWidth: CGFloat = 0.0
    let profileBorderColor: UIColor? = nil
    userProfileImageNode.style.preferredSize = profileImageSize
    userProfileImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(profileBorderWidth, profileBorderColor)
    userProfileImageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: profileImageSize)
  }

  
}
