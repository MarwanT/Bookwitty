//
//  BookDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsHeaderNode: ASDisplayNode {
  fileprivate var imageNode: ASNetworkImageNode
  fileprivate var titleNode: ASTextNode
  fileprivate var authorNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    super.init()
    initializeComponents()
  }
  
  func initializeComponents() {
    imageNode.isLayerBacked = true
    titleNode.isLayerBacked = true
    authorNode.isLayerBacked = true
  }
}

extension BookDetailsHeaderNode {
  struct Configuration {
    var titleTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var authorTextColor = ThemeManager.shared.currentTheme.colorNumber19()
  }
}
