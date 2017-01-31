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
    // TODO: Set proper images here when available
    showHidePasswordButton.setBackgroundImage(UIImage(color: UIColor.blue), for: UIControlState.normal)
    showHidePasswordButton.setBackgroundImage(UIImage(color: UIColor.green), for: UIControlState.selected)
    showHidePasswordButton.addTarget(self, action: #selector(self.showHidePasswordButtonTouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
    showHidePasswordButton.isSelected = false
    
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
  }
}
