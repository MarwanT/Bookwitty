//
//  CardPostInfoNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

typealias CardPostInfoNodeData = (name: String, date: String, imageUrl: String?)

class CardPostInfoNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var userProfileImageNode: ASNetworkImageNode
  var arrowDownImageNode: ASImageNode
  var userNameTextNode: ASTextNode
  var postDateTextNode: ASTextNode

  private let userProfileImageDimension: CGFloat = 44.0
  private let downArrowButtonSize: CGSize = CGSize(width: 30.0, height: 30.0)

  var data: CardPostInfoNodeData? {
    didSet {
      loadData()
    }
  }

  override init() {
    userProfileImageNode = ASNetworkImageNode()
    arrowDownImageNode = ASImageNode()
    userNameTextNode = ASTextNode()
    postDateTextNode = ASTextNode()
    super.init()
    addSubnode(userNameTextNode)
    addSubnode(postDateTextNode)
    addSubnode(userProfileImageNode)
    addSubnode(arrowDownImageNode)
    setupNode()
  }

  private func setupNode() {
    let profileImageSize: CGSize = CGSize(width: userProfileImageDimension, height: userProfileImageDimension)
    let profileBorderWidth: CGFloat = 0.0
    let profileBorderColor: UIColor? = nil
    userProfileImageNode.style.preferredSize = profileImageSize
    userProfileImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(profileBorderWidth, profileBorderColor)
    userProfileImageNode.defaultImage = UIImage(color: ASDisplayNodeDefaultPlaceholderColor(), size: profileImageSize)

    arrowDownImageNode.image = #imageLiteral(resourceName: "downArrow")
    arrowDownImageNode.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    arrowDownImageNode.style.preferredSize = downArrowButtonSize

    userNameTextNode.maximumNumberOfLines = 1
    postDateTextNode.maximumNumberOfLines = 1
  }

  private func loadData() {
    guard let data = data else {
      return
    }

    if !data.name.isEmpty {
      userNameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
        .append(text: data.name, color: ThemeManager.shared.currentTheme.colorNumber19()).attributedString
    }

    if !data.date.isEmpty {
      postDateTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2).append(text: data.date).attributedString
    }

    if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
      userProfileImageNode.url = URL(string: imageUrl)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //Add the User Profile Image - Vertical Stack [Name - Date] - Image ArrowDown
    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.style.flexShrink = 1.0
    verticalStack.style.flexGrow = 1.0
    verticalStack.justifyContent = .center
    verticalStack.alignItems = .start
    verticalStack.children = [userNameTextNode, postDateTextNode]

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                      spacing: 10,
                                                      justifyContent: .center,
                                                      alignItems: .stretch,
                                                      children: [userProfileImageNode, verticalStack, arrowDownImageNode])

    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: internalMargin, left: internalMargin, bottom: internalMargin, right: internalMargin), child: horizontalStackSpec)
  }

}
