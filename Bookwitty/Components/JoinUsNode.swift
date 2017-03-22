//
//  JoinUsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class JoinUsNode: ASDisplayNode {
  fileprivate let titleTextNode: ASTextNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let getStartedButtonNode: ASButtonNode
  fileprivate let alreadyHaveAnAccountTextNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    titleTextNode = ASTextNode()
    descriptionTextNode = ASTextNode()
    getStartedButtonNode = ASButtonNode()
    alreadyHaveAnAccountTextNode = ASTextNode()
    super.init()
  }
}

extension JoinUsNode {
  struct Configuration {
    let textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    let buttonTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    let linkTextColor = ThemeManager.shared.currentTheme.colorNumber16()
    let signInTextColor = ThemeManager.shared.currentTheme.colorNumber19()
    let externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
