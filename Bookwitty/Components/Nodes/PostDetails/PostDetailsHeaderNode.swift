//
//  PostDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PostDetailsHeaderNode: ASCellNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASTextNode
  let profileBarNode: PenNameFollowNode
  let actionBarNode: CardActionBarNode
  fileprivate let separator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode

  var title: String? {
    didSet {
      textNode.attributedText = title.isEmptyOrNil() ? nil : AttributedStringBuilder(fontDynamicType: FontDynamicType.title1).append(text: title!).attributedString
    }
  }
  var image: String? {
    didSet {
      imageNode.url = image.isEmptyOrNil() ? nil : URL(string: image!)
    }
  }
  var date: String? {
    didSet {
      profileBarNode.biography = date
    }
  }
  var penName: PenName? {
    didSet {
      profileBarNode.penName = penName?.name
      profileBarNode.imageUrl = penName?.avatarUrl
      profileBarNode.following = penName?.following ?? false
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASTextNode()
    profileBarNode = PenNameFollowNode()
    actionBarNode = CardActionBarNode()
    separator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  override func didLoad() {
    imageNode.contentMode = .scaleAspectFill
  }

  func initializeNode() {
    //Enable dimming node
    actionBarNode.hideDim = false
    
    //Separator Styling
    separator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bottomSeparator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    bottomSeparator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    //Post Iamge
    imageNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 200.0)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.animatedImagePaused = true
    //Post Title
    textNode.style.flexGrow = 1
    textNode.style.flexShrink = 1

  }

  func setWitValue(witted: Bool, wits: Int) {
    actionBarNode.setWitButton(witted: witted, wits: wits)
  }

  func setDimValue(dimmed: Bool, dims: Int) {
    actionBarNode.setDimValue(dimmed: dimmed, dims: dims)
  }
  
  func sidesEdgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackSpec = ASStackLayoutSpec.vertical()
    vStackSpec.spacing = 0.0

    let textInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: textNode)
    let separatorInset =  ASInsetLayoutSpec(insets: sidesEdgeInset(), child: separator)
    let bottomSeparatorInset =  ASInsetLayoutSpec(insets: sidesEdgeInset(), child: bottomSeparator)

    let vStackActionBarSpec = ASStackLayoutSpec.vertical()
    vStackActionBarSpec.children = [separatorInset, actionBarNode, bottomSeparatorInset]

    vStackSpec.children = [imageNode, ASLayoutSpec.spacer(height: contentSpacing),
                           textInsetSpec, profileBarNode, vStackActionBarSpec]
    return vStackSpec
  }
}
