//
//  NewsCollectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentsCountCellNode: ASCellNode {
  var label: ASTextNode
  
  var configuration = Configuration() {
    didSet {
      refreshNode()
    }
  }

  override init() {
    label = ASTextNode()
    super.init()
    initialize()
  }
  
  private func initialize() {
    automaticallyManagesSubnodes = true
    label.isLayerBacked = true
  }
  
  // MARK: LAYOUT
  //=============
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let titleInsetsSpec = ASInsetLayoutSpec(insets: configuration.internalMargin, child: label)
    return titleInsetsSpec
  }

  // MARK: APIs
  //===========
  var text: String {
    get {
      return label.attributedText?.string ?? ""
    }
    set {
      label.attributedText = AttributedStringBuilder(fontDynamicType: configuration.fontBookSelected).append(text: newValue, color: configuration.textColor).attributedString
    }
  }
  
  // MARK: HELPERS
  //==============
  private func refreshNode() {
    if let currentText = label.attributedText?.string {
      text = currentText
    }
    applyTheme()
    setNeedsLayout()
  }
}

// MARK: - Configuration
extension CommentsCountCellNode {
  struct Configuration {
    var internalMargin = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin() - 8,
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin() - 8,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var fontBookSelected = FontDynamicType.Reference.type8
    var textColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }
}

// MARK: - Theme
extension CommentsCountCellNode: Themeable {
  func applyTheme() {}
}
