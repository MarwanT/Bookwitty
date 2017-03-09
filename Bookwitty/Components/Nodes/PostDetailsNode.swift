//
//  PostDetailsNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PostDetailsNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let headerNode: PostDetailsHeaderNode
  fileprivate let descriptionNode: ASTextNode

  var title: String? {
    didSet {
      headerNode.title = title
    }
  }
  var coverImage: String? {
    didSet {
        headerNode.image = coverImage
    }
  }
  var body: String? {
    didSet {
      let attributed = body.isEmptyOrNil() ? nil : AttributedStringBuilder(fontDynamicType: FontDynamicType.title3).append(text: body!).attributedString
      descriptionNode.attributedText = attributed
    }
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    automaticallyManagesContentSize = true
    initializeNode()
  }

  func initializeNode() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    descriptionNode.style.flexGrow = 1.0
    descriptionNode.style.flexShrink = 1.0
  }
}
