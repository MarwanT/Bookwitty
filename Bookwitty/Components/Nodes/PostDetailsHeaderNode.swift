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
  fileprivate let profileBarNode: ASDisplayNode
  fileprivate let actionBarNode: CardActionBarNode
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

  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASTextNode()
    profileBarNode = ASDisplayNode()
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
    //Separator Styling
    separator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bottomSeparator.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1.0)
    bottomSeparator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    //Post Iamge
    imageNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 200.0)
    imageNode.backgroundColor = UIColor.bwKeppel
    //Post Title
    textNode.style.flexGrow = 1
    textNode.style.flexShrink = 1
    //Profile Bar
    profileBarNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 45.0)
    profileBarNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
    //Action Bar
  }
}
