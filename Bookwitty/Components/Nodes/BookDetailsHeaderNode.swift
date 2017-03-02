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
  
  // MARK: APIs
  var imageURL: URL? {
    get {
      return imageNode.url
    }
    set(url) {
      imageNode.url = url
    }
  }
  
  var title: String? {
    get {
      return titleNode.attributedText?.string
    }
    set(text) {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title3)
        .append(text: text ?? "", color: configuration.titleTextColor).attributedString
    }
  }
  
  var author: String? {
    get {
      return authorNode.attributedText?.string
    }
    set(text) {
      authorNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: text ?? "", color: configuration.authorTextColor).attributedString
    }
  }
}

extension BookDetailsHeaderNode {
  struct Configuration {
    var titleTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var authorTextColor = ThemeManager.shared.currentTheme.colorNumber19()
  }
}
