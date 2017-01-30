//
//  InformativeInputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class InformativeInputField: InputField {
  var indicatorImageView: UIImageView!
  
  override func setupLayout() {
    super.setupLayout()
    
    indicatorImageView = UIImageView(frame:CGRect(
      x: 0, y: 0, width: configuration.rightSideViewWidth,
       height: configuration.rightSideViewHeight))
    indicatorImageView.backgroundColor = UIColor.bwAliceBlue
    
    textField.rightViewMode = UITextFieldViewMode.always
  }
  
  override func refreshViewForStatus() {
    UIView.animate(withDuration: 0.55) {
      switch self.status {
      case .empty:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.indicatorImageView
      case .valid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.indicatorImageView
      case .inValid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelInvalidTextColor
        self.textField.textColor = self.configuration.textFieldInvalidTextColor
        self.textField.rightView = self.invalidationImageView
      }
    }
  }
}
