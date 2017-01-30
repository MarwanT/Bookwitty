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
  var invalidationImageView: UIImageView!
  
  override func setupLayout() {
    super.setupLayout()
    
    showHidePasswordButton = UIButton(type: UIButtonType.custom)
    showHidePasswordButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    // TODO: Set proper images here when available
    showHidePasswordButton.setBackgroundImage(UIImage(color: UIColor.blue), for: UIControlState.normal)
    showHidePasswordButton.setBackgroundImage(UIImage(color: UIColor.green), for: UIControlState.selected)
    showHidePasswordButton.addTarget(self, action: #selector(self.showHidePasswordButtonTouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
    showHidePasswordButton.isSelected = false
    
    textField.isSecureTextEntry = true
    textField.rightViewMode = UITextFieldViewMode.always
  }
  
  func showHidePasswordButtonTouchUpInside(sender: UIButton) {
  }
}
