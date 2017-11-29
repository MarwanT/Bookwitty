//
//  ASWitButton.swift
//  Bookwitty
//
//  Created by Marwan  on 11/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class ASWitButton: ASButtonNode {
  fileprivate(set) var displayMode: DisplayMode = .lightWeight
  
  var configuration = Configuration() {
    didSet {
      applyTheme()
      setNeedsLayout()
    }
  }
  
  override init() {
    super.init()
    applyTheme()
    initialize()
  }
  
  private func initialize() {
  }
}

// MARK: - THEMEABLE
                                     //****\\
extension ASWitButton {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    switch displayMode {
    case .lightWeight:
      let buttonFont = configuration.font
      let textColor = theme.defaultGrayedTextColor()
      let selectedTextColor = theme.defaultButtonColor()
      
      style.preferredSize.height = configuration.height
      style.preferredSize.width = 50.0
      
      setTitle(Strings.wit_it(), with: buttonFont, with: textColor, for: .normal)
      setTitle(Strings.witted(), with: buttonFont, with: selectedTextColor, for: .selected)
      contentHorizontalAlignment = ASHorizontalAlignment.right
      
      cornerRadius = 0
      borderWidth = 0
    case .heavyWeight:
      let buttonFont = configuration.font
      let buttonBackgroundImage = theme.defaultBackgroundColor().image()
      let selectedButtonBackgroundImage = theme.defaultButtonColor().image()
      let textColor = theme.defaultButtonColor()
      let selectedTextColor = theme.colorNumber23()
      
      style.preferredSize.height = configuration.height
      style.preferredSize.width = 75.0
      
      setBackgroundImage(buttonBackgroundImage, for: .normal)
      setBackgroundImage(selectedButtonBackgroundImage, for: .selected)
      
      setTitle(Strings.wit_it(), with: buttonFont, with: textColor, for: .normal)
      setTitle(Strings.witted(), with: buttonFont, with: selectedTextColor, for: .selected)
      
      cornerRadius = 2.0
      borderColor = theme.defaultButtonColor().cgColor
      borderWidth = 2
      clipsToBounds = true
    }
  }
}

// MARK: - DISPLAY MODE
                                   //****\\
extension ASWitButton {
  enum DisplayMode {
    case lightWeight
    case heavyWeight
  }
}

// MARK: - CONFIGURATION
                                   //****\\
extension ASWitButton {
  struct Configuration {
    var font = FontDynamicType.subheadline.font
    var height: CGFloat = 45.0
  }
}
