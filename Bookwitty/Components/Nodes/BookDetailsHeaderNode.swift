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
    automaticallyManagesSubnodes = true
    imageNode.isLayerBacked = true
    titleNode.isLayerBacked = true
    authorNode.isLayerBacked = true
  }
  
  // MARK: APIs
  var imageURL: URL? {
    didSet {
      imageNode.url = imageURL
      setNeedsLayout()
    }
  }
  
  var title: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title3)
        .append(text: title ?? "", color: configuration.titleTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  var author: String? {
    didSet {
      authorNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: author ?? "", color: configuration.authorTextColor).attributedString
    }
  }
}

// MARK: - Configuration
extension BookDetailsHeaderNode {
  struct Configuration {
    var titleTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var authorTextColor = ThemeManager.shared.currentTheme.colorNumber19()
    var backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    fileprivate var labelsSpacing: CGFloat = 5
    fileprivate var imageNodePreferredSize: CGSize = CGSize(width: 100, height: 150)
    fileprivate var generalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.booksVerticalSpacing(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.booksVerticalSpacing(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    fileprivate var horizontalEdgeInsets = UIEdgeInsets(
      top: 0,
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
