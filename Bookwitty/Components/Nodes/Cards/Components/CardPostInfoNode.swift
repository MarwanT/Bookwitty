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

protocol CardPostInfoNodeDelegate: class {
  func cardInfoNode(cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any)
}

class CardPostInfoNode: ASDisplayNode {
  enum Action {
    case userProfile
    case actionInfo
  }
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  var userProfileImageNode: ASNetworkImageNode
  var arrowDownImageNode: ASImageNode
  var userNameTextNode: ASTextNode
  var postDateTextNode: ASTextNode
  weak var delegate: CardPostInfoNodeDelegate?

  private let userProfileImageDimension: CGFloat = 45.0
  private let downArrowButtonSize: CGSize = CGSize(width: 45.0, height: 45.0)

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
    userProfileImageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    userProfileImageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    userProfileImageNode.animatedImagePaused = true

    arrowDownImageNode.image = #imageLiteral(resourceName: "downArrow")
    arrowDownImageNode.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    arrowDownImageNode.style.preferredSize = downArrowButtonSize
    arrowDownImageNode.isHidden = true

    userNameTextNode.maximumNumberOfLines = 1
    postDateTextNode.maximumNumberOfLines = 1

    userNameTextNode.truncationMode = NSLineBreakMode.byTruncatingTail
    userNameTextNode.truncationMode = NSLineBreakMode.byTruncatingTail

    userNameTextNode.addTarget(self, action: #selector(userNameTouchUpInside(_:)), forControlEvents: .touchUpInside)
    postDateTextNode.addTarget(self, action: #selector(postDateTouchUpInside(_:)), forControlEvents: .touchUpInside)
    userProfileImageNode.addTarget(self, action: #selector(userProfileImageTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func userNameTouchUpInside(_ sender: Any?) {
    guard let sender = sender else { return }
    delegate?.cardInfoNode(cardPostInfoNode: self, didRequestAction: CardPostInfoNode.Action.userProfile, forSender: sender)
  }

  func postDateTouchUpInside(_ sender: Any?) {
    guard let sender = sender else { return }
    delegate?.cardInfoNode(cardPostInfoNode: self, didRequestAction: CardPostInfoNode.Action.userProfile, forSender: sender)
  }

  func userProfileImageTouchUpInside(_ sender: Any?) {
    guard let sender = sender else { return }
    delegate?.cardInfoNode(cardPostInfoNode: self, didRequestAction: CardPostInfoNode.Action.userProfile, forSender: sender)
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
      postDateTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: data.date, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
        .attributedString
    }

    if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
      userProfileImageNode.url = URL(string: imageUrl)
    }
  }

  private func spacer(width: CGFloat = 0.0, flexGrow: CGFloat = 1.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      if(width == 0) {
        style.flexGrow = flexGrow
      }
      style.width = ASDimensionMake(width)
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

    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: internalMargin, left: internalMargin, bottom: internalMargin, right: 0), child: horizontalStackSpec)
  }

}
