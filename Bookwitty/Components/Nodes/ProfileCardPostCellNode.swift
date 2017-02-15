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
  private let followerText: String = localizedString(key: "number_of_follower_text", defaultValue: "Followers")

  private var userProfileImageNode: ASNetworkImageNode
  private var userNameTextNode: ASTextNode
  private var followersTextNode: ASTextNode
  private var descriptionNode: ASTextNode

  var userName: String? {
    didSet {
      if let userName = userName {
        userNameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: userName, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }
  var followersCount: String? {
    didSet {
      if let followersCount = followersCount {
        followersTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: followersCount)
          .append(text: " ")
          .append(text: followerText, fontDynamicType: .caption2)
          .attributedString
      }
    }
  }
  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        userProfileImageNode.url = URL(string: imageUrl)
      }
    }
  }

  override init() {
    userProfileImageNode = ASNetworkImageNode()
    userNameTextNode = ASTextNode()
    followersTextNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(userProfileImageNode)
    addSubnode(userNameTextNode)
    addSubnode(followersTextNode)
    addSubnode(descriptionNode)
    setupNodes()
  }

  func setupNodes() {
    userNameTextNode.maximumNumberOfLines = 1
    followersTextNode.maximumNumberOfLines = 1
    descriptionNode.maximumNumberOfLines = 4

    let profileBorderWidth: CGFloat = 0.0
    let profileBorderColor: UIColor? = nil
    userProfileImageNode.style.preferredSize = profileImageSize
    userProfileImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(profileBorderWidth, profileBorderColor)
    userProfileImageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: profileImageSize)
  }

  
}
