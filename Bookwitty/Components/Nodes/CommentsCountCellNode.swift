//
//  NewsCollectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentsCountCellNode: ASCellNode {
  var configuration = Configuration() {
    didSet {
      refreshNode()
    }
  }
  
  // MARK: HELPERS
  //==============
  private func refreshNode() {
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
    var fontBookSelected: FontDynamicType = .subheadline
    var textColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }
}

// MARK: - Theme
extension CommentsCountCellNode: Themeable {
  func applyTheme() {}
}
