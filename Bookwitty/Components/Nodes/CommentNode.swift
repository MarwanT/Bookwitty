//
//  CommentNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentNode: ASCellNode {
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let fullNameNode: ASTextNode
  fileprivate let dateNode: ASTextNode
  fileprivate let messageNode: ASTextNode
  fileprivate let actionBar: CardActionBarNode
  
  var configuration = Configuration()
  
  override init() {
    imageNode = ASNetworkImageNode()
    fullNameNode = ASTextNode()
    dateNode = ASTextNode()
    messageNode = ASTextNode()
    actionBar = CardActionBarNode()
    super.init()
}

// MARK: Configuration declaration
extension CommentNode {
  struct Configuration {
    private static var subnodesSpace = ThemeManager.shared.currentTheme.cardInternalMargin()
    var nameColor: UIColor = ThemeManager.shared.currentTheme.colorNumber19()
    var defaultTextColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
    var imageBorderWidth: CGFloat = 0.0
    var imageBorderColor: UIColor? = nil
    var imageNodeInsets = UIEdgeInsetsMake(0, 0, 0, Configuration.subnodesSpace)
    var bodyInsetTop: CGFloat = Configuration.subnodesSpace - 5
    var titleDateVerticalSpace: CGFloat = 5
  }
}
