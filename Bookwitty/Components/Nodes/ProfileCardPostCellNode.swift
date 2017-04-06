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
  var showsInfoNode: Bool = false
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = ProfileCardPostContentNode()
    super.init()
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class ProfileCardPostContentNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let headerHeight: CGFloat = 70.0
  private let profileImageSize: CGSize = CGSize(width: 70.0, height: 70.0)

  private var userProfileImageNode: ASNetworkImageNode
  private var userNameTextNode: ASTextNode
  private var followersTextNode: ASTextNode
  private var descriptionNode: ASTextNode

  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }
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
      if let followersCount = followersCount, let number: Int = Int(followersCount) {
        followersTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: Strings.followers(number: number), fontDynamicType: .caption2)
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

    userProfileImageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue

    let profileBorderWidth: CGFloat = 0.0
    let profileBorderColor: UIColor? = nil
    userProfileImageNode.style.preferredSize = profileImageSize
    userProfileImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(profileBorderWidth, profileBorderColor)
    userProfileImageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: profileImageSize)
  }

  private func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var verticalChildNodes: [ASLayoutElement] = []
    verticalChildNodes.append(userNameTextNode)
    if (isValid(followersCount)) {
      verticalChildNodes.append(spacer(height: 5.0))
      verticalChildNodes.append(followersTextNode)
    }

    let verticalChildStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 0,
                                               justifyContent: .center,
                                               alignItems: .start,
                                               children: verticalChildNodes)
    verticalChildStack.style.height = ASDimensionMake(headerHeight)
    verticalChildStack.style.flexShrink = 1.0

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: internalMargin,
                                                justifyContent: .start,
                                                alignItems: .stretch,
                                                children: [userProfileImageNode, verticalChildStack])

    let verticalParentNodes: [ASLayoutElement] = isValid(articleDescription)
      ? [horizontalStackSpec, descriptionNode]
      : [horizontalStackSpec]

    let verticalParentStackSpec = ASStackLayoutSpec(direction: .vertical,
                                                spacing: internalMargin,
                                                justifyContent: .start,
                                                alignItems: .stretch,
                                                children: verticalParentNodes)


    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: verticalParentStackSpec)
  }

}
