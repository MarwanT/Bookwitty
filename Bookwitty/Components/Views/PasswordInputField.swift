//
//  PasswordInputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PasswordInputField: InputField {
  var showHidePasswordButton: UIButton!
  
  override func setupLayout() {
    super.setupLayout()
    
    showHidePasswordButton = UIButton(type: UIButtonType.custom)
    showHidePasswordButton.frame = CGRect(
      x: 0, y: 0, width: configuration.rightSideViewWidth,
      height: configuration.rightSideViewHeight)
    showHidePasswordButton.setBackgroundImage(#imageLiteral(resourceName: "show"), for: UIControlState.normal)
    showHidePasswordButton.setBackgroundImage(#imageLiteral(resourceName: "hide"), for: UIControlState.selected)
    showHidePasswordButton.addTarget(self, action: #selector(self.showHidePasswordButtonTouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
    showHidePasswordButton.isSelected = false
    showHidePasswordButton.tintColor = ThemeManager.shared.currentTheme.colorNumber18()
    
    textField.isSecureTextEntry = true
    textField.rightViewMode = UITextFieldViewMode.always
  }
  
  override func refreshViewForStatus() {
    UIView.animate(withDuration: 0.55) {
      switch self.status {
      case .empty:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.showHidePasswordButton
      case .valid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.showHidePasswordButton
      case .inValid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelInvalidTextColor
        self.textField.textColor = self.configuration.textFieldInvalidTextColor
        self.textField.rightView = self.invalidationImageView
      }
    }
  }
  
  func showHidePasswordButtonTouchUpInside(sender: UIButton) {
    showHidePasswordButton.isSelected = !showHidePasswordButton.isSelected
    textField.isSecureTextEntry = !showHidePasswordButton.isSelected
    
    if textField.isSecureTextEntry {
      showHidePasswordButton.tintColor = ThemeManager.shared.currentTheme.colorNumber18()
    } else {
      showHidePasswordButton.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    }
  }
}
