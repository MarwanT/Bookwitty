//
//  DetailsInfoCellNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DetailsInfoCellNode: ASCellNode {
  fileprivate var keyTextNode: ASTextNode
  fileprivate var valueTextNode: ASTextNode
  
  private var configuration = Configuration()
  
  override init() {
    keyTextNode = ASTextNode()
    valueTextNode = ASTextNode()
    super.init()
  }
}

extension DetailsInfoCellNode {
  struct Configuration {
    static let minimumHeight: CGFloat = 45
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    let stackEdgeInsets = UIEdgeInsets(
      top: 10, left: 0, bottom: 10,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    let keyNodeEdgeInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: 0,
      right: (ThemeManager.shared.currentTheme.generalExternalMargin() * 2))
  }
}
