//
//  ASWitButton.swift
//  Bookwitty
//
//  Created by Marwan  on 11/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol ASWitButtonDelegate {
  func witButtonTapped(_ witButton: ASWitButton, witted: Bool,
                       reactionBlock: @escaping (_ success: Bool) -> Void,
                       completionBlock: @escaping (_ success: Bool) -> Void)
}

class ASWitButton: ASButtonNode {
  fileprivate(set) var displayMode: DisplayMode = .lightWeight
  
  var configuration = Configuration() {
    didSet {
      applyTheme()
      setNeedsLayout()
    }
  }
  
  var delegate: ASWitButtonDelegate?
  
  override init() {
    super.init()
    applyTheme()
    initialize()
  }
  
  private func initialize() {
    addTarget(self, action: #selector(touchUpInside), forControlEvents: .touchUpInside)
  }
  
  func initialize(with displayMode: DisplayMode) {
    self.displayMode = displayMode
    applyTheme()
    setNeedsLayout()
  }
  
  // MARK: APIs
  //===========
  var witted: Bool {
    get {
      return isSelected
    }
    set {
      isSelected = newValue
    }
  }
  
  // MARK: ACTIONS
  //==============
  func touchUpInside() {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post(
        name: AppNotification.callToAction, object: CallToAction.wit)
      return
    }
    
    isEnabled = false
    delegate?.witButtonTapped(self, witted: isSelected, reactionBlock: {
      [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      guard success else { return }
      strongSelf.witted = !strongSelf.witted
    }, completionBlock: {
      [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      strongSelf.isEnabled = true
      if !success {
        strongSelf.witted = !strongSelf.witted
      }
    })
  }
}

// MARK: - THEMEABLE
                                     //****\\
extension ASWitButton {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    switch displayMode {
    case .lightWeight:
      let buttonFont = configuration.lightFont
      let textColor = theme.defaultGrayedTextColor()
      let selectedTextColor = theme.defaultButtonColor()
      
      style.preferredSize.height = configuration.height
      style.preferredSize.width = 50.0
      
      setTitle(Strings.wit_it(), with: buttonFont, with: textColor, for: .normal)
      setTitle(Strings.witted(), with: buttonFont, with: selectedTextColor, for: .selected)
      contentHorizontalAlignment = ASHorizontalAlignment.middle
      contentEdgeInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
      
      cornerRadius = 0
      borderWidth = 0
    case .heavyWeight:
      let buttonFont = configuration.heavyFont
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
    fileprivate var lightFont = FontDynamicType.Reference.type18.font
    fileprivate var heavyFont = FontDynamicType.Reference.type8.font
    var height: CGFloat = 45.0
  }
}
