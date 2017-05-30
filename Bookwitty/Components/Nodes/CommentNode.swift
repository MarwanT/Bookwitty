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
  
  var mode = Mode.primary {
    didSet {
      setNeedsLayout()
    }
  }
  
  var configuration = Configuration()
  
  override init() {
    imageNode = ASNetworkImageNode()
    fullNameNode = ASTextNode()
    dateNode = ASTextNode()
    messageNode = ASTextNode()
    actionBar = CardActionBarNode()
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.style.preferredSize = configuration.imageSize
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(
      configuration.imageBorderWidth, configuration.imageBorderColor)
    
    actionBar.setup(forFollowingMode: false)
    actionBar.configuration.externalHorizontalMargin = 0
    actionBar.hideDim = false
    actionBar.hideReplyButton = false
    actionBar.hideShareButton = true
  }
  
  // MARK: Data Setters
  var imageURL: URL?  {
    didSet {
      imageNode.url = imageURL
      imageNode.setNeedsLayout()
    }
  }
  
  var fullName: String? {
    didSet {
      fullNameNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
        .append(text: fullName ?? "", color: configuration.nameColor).attributedString
      fullNameNode.setNeedsLayout()
      setNeedsLayout()
    }
  }
  
  var date: Date? {
    didSet {
      dateNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: date?.formatted() ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  var message: String? {
    didSet {
      messageNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
        .append(text: message ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  func setWitValue(witted: Bool, wits: Int) {
    actionBar.setWitButton(witted: witted, wits: wits)
  }
  
  func setDimValue(dimmed: Bool, dims: Int) {
    actionBar.setDimValue(dimmed: dimmed, dims: dims)
  }
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

// MARK: Modes declaration
extension CommentNode {
  enum Mode {
    case primary
    case secondary
  }
}

