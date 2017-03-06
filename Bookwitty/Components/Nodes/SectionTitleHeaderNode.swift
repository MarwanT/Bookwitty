//
//  SectionTitleHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class SectionTitleHeaderNode: ASDisplayNode {
  fileprivate let verticalBarNode: ASDisplayNode
  fileprivate let horizontalBarNode: ASDisplayNode
  fileprivate let titleNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    verticalBarNode = ASDisplayNode()
    horizontalBarNode = ASDisplayNode()
    titleNode = ASTextNode()
    super.init()
    initializeComponents()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    verticalBarColor = configuration.verticalBarColor
    horizontalBarColor = configuration.horizontalBarColor
  }
}

extension SectionTitleHeaderNode {
  struct Configuration {
    var verticalBarColor = ThemeManager.shared.currentTheme.colorNumber6()
    var horizontalBarColor = ThemeManager.shared.currentTheme.colorNumber5()
    fileprivate var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var verticalBarWidth: CGFloat = 8
    fileprivate var minimumHeight: CGFloat = 60
    fileprivate var verticalBarEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    fileprivate var horizontalBarEdgeInsets = UIEdgeInsets(top: 0, left: 80 - 8, bottom: 0, right: 0)
    fileprivate var titleEdgeInsets = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 0)
  }
}
