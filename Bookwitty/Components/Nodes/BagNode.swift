//
//  BagNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit


class BagNode: ASDisplayNode {
  fileprivate let textNode: ASTextNode
  fileprivate let shopOnlineButton: ASButtonNode
  
  var configuration = Configuration()
  
  override init() {
    textNode = ASTextNode()
    shopOnlineButton = ASButtonNode()
    super.init()
  }
}

// MARK: - Declaration
extension BagNode {
  struct Configuration {
    fileprivate let shopOnlineButtonTitleColor = ThemeManager.shared.currentTheme.colorNumber23()
    fileprivate let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate let backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()
    fileprivate let edgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
