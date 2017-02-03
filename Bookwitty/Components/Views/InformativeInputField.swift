//
//  InformativeInputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol InformativeInputFieldDelegate {
  func informativeInputFieldDidTapField(informativeInputField: InformativeInputField)
}

class InformativeInputField: InputField {
  var indicatorButton: UIButton!
  
  var informativeInputFieldDelegate: InformativeInputFieldDelegate?
  
  var text: String? {
    get {
      return textField.text
    }
    
    set {
      textField.text = newValue
    }
  }
  
  override func setupLayout() {
    super.setupLayout()
    
    indicatorButton = UIButton(type: UIButtonType.custom)
    indicatorButton.frame = CGRect(
      x: 0, y: 0, width: configuration.rightSideViewWidth,
      height: configuration.rightSideViewHeight)
    indicatorButton.setBackgroundImage(#imageLiteral(resourceName: "rightArrow"), for: UIControlState.normal)
    indicatorButton.setBackgroundImage(#imageLiteral(resourceName: "rightArrow"), for: UIControlState.selected)
    indicatorButton.addTarget(self, action: #selector(self.indicatorButtonTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
    indicatorButton.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    
    textField.rightViewMode = UITextFieldViewMode.always
    textField.isEnabled = false
    textField.rightView = indicatorButton
    
    // Add transparent view above the text field to capture taps
    let overlayTapView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    addSubview(overlayTapView)
    overlayTapView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: textField)
    
    // Add Tap Gesture Recognizer
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textFieldTap(sender:)))
    overlayTapView.addGestureRecognizer(tapGesture)
  }
  
  override func becomeFirstResponder() -> Bool {
    self.textField.becomeFirstResponder()
    self.textField.resignFirstResponder()
    return true
  }
  
  override func refreshViewForStatus() {
    
    UIView.animate(withDuration: 0.55) {
      switch self.status {
      case .empty:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.indicatorButton
      case .valid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightView = self.indicatorButton
      case .inValid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelInvalidTextColor
        self.textField.textColor = self.configuration.textFieldInvalidTextColor
        self.textField.rightView = self.invalidationImageView
      }
    }
  }
  
  func textFieldTap(sender: Any?) {
    self.textField.becomeFirstResponder()
    self.textField.resignFirstResponder()

    informativeInputFieldDelegate?.informativeInputFieldDidTapField(informativeInputField: self)
  }
  
  func indicatorButtonTouchUpInside(_ sender: Any?) {
    textFieldTap(sender: nil)
  }
}
