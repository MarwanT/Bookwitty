//
//  GetStarted.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/11/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class GetStarted: ASDisplayNode {

  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init() {
    super.init()
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true
  }
}

//MARK: - Themeable Implementation
extension GetStarted: Themeable {
  func applyTheme() {
    //TODO: Empty Implementation
  }
}

//MARK: - Configuration Declaration
extension GetStarted {
  struct Configuration {
    let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    let margin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
    let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
    let iconTintColor = ThemeManager.shared.currentTheme.colorNumber2()
    let vInset: CGFloat = 50.0
  }
}
