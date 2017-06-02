//
//  WriteCommentNode.swift
//  Bookwitty
//
//  Created by Marwan  on 6/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class WriteCommentNode: ASCellNode {
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASEditableTextNode
  fileprivate let overlayNode: ASControlNode
  
  var configuration = Configuration()
  
  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASEditableTextNode()
    overlayNode = ASControlNode()
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.isLayerBacked = true
  
    placeholder = "What are your thoughts?"
    textNode.style.flexGrow = 1.0
    textNode.textContainerInset = configuration.textContainerInset
  }
}

extension WriteCommentNode {
  struct Configuration {
    private static var subnodesSpace = ThemeManager.shared.currentTheme.cardInternalMargin()
    fileprivate var textContainerInset = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin())
    
    var externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var imageNodeInsets = UIEdgeInsetsMake(0, 0, 0, Configuration.subnodesSpace)
    var imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
    var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var placeholderTextColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    var textNodeBorderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    var textNodeBorderWidth: CGFloat = 0.5
    var textNodeMinimumHeight: CGFloat = 100
  }
}
