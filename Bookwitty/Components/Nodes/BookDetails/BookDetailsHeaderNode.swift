//
//  BookDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol BookDetailsHeaderNodeDelegate: class {
  func photoCard(node: BookDetailsHeaderNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
}

class BookDetailsHeaderNode: ASCellNode {
  fileprivate var imageNode: ASNetworkImageNode
  fileprivate var titleNode: ASTextNode
  fileprivate var authorNode: ASTextNode

  weak var delegate: BookDetailsHeaderNodeDelegate?
  var configuration = Configuration()
  
  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    super.init()
    initializeComponents()
    applyTheme()
    addTargets()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    titleNode.isLayerBacked = true
    authorNode.isLayerBacked = true
    
    imageNode.style.preferredSize = configuration.imageNodePreferredSize
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
  }

  func addTargets() {
    imageNode.addTarget(self, action: #selector(photoImageTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func photoImageTouchUpInside(_ sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      return
    }

    delegate?.photoCard(node: self, requestToViewImage: image, from: sender)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalLayoutSpec = ASStackLayoutSpec(
      direction: .vertical,
      spacing: configuration.labelsSpacing,
      justifyContent:ASStackLayoutJustifyContent.start,
      alignItems: ASStackLayoutAlignItems.start,
      children: [titleNode, authorNode])
    let verticalInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.horizontalEdgeInsets,
      child: verticalLayoutSpec)
    verticalInsetsSpec.style.flexShrink = 1.0
    verticalInsetsSpec.style.flexGrow = 1.0
    
    let horizontalLayoutSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: ASStackLayoutJustifyContent.start,
      alignItems: ASStackLayoutAlignItems.stretch,
      children: [imageNode, verticalInsetsSpec])
    
    let generalInsetSpec = ASInsetLayoutSpec(
      insets: configuration.generalEdgeInsets,
      child: horizontalLayoutSpec)
    
    return generalInsetSpec
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
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
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

// MARK: - Themeable
extension BookDetailsHeaderNode: Themeable {
  func applyTheme() {
    backgroundColor = configuration.backgroundColor
  }
}
