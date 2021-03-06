//
//  InputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

protocol InputFieldDelegate: class {
  func inputFieldShouldReturn(inputField: InputField) -> Bool
}

struct InputFieldConfiguration {
  var descriptionLabelText: String?
  var desriptionLabelDefaultTextColor: UIColor
  var desriptionLabelInvalidTextColor: UIColor
  var textFieldPlaceholder: String?
  var textFieldDefaultTextColor: UIColor
  var textFieldInvalidTextColor: UIColor
  var textFieldDefaultText: String?
  var invalidationIcon: UIImage?
  var invalidationErrorMessage: String?
  var returnKeyType: UIReturnKeyType
  var rightSideViewHeight: CGFloat
  var rightSideViewWidth: CGFloat
  var keyboardType: UIKeyboardType
  var autocorrectionType: UITextAutocorrectionType
  var autocapitalizationType: UITextAutocapitalizationType
  var textFieldMinimumHeight: CGFloat
  var rightMargin: CGFloat
  
  init(descriptionLabelText: String? = nil, desriptionLabelDefaultTextColor: UIColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor(), desriptionLabelInvalidTextColor: UIColor = ThemeManager.shared.currentTheme.defaultErrorColor(), textFieldPlaceholder: String? = nil, textFieldDefaultTextColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor(), textFieldInvalidTextColor: UIColor = ThemeManager.shared.currentTheme.defaultErrorColor(), textFieldDefaultText: String? = nil, textFieldMinimumHeight: CGFloat = 44, invalidationIcon: UIImage? = nil, invalidationErrorMessage: String? = "Invalid Field", returnKeyType: UIReturnKeyType = UIReturnKeyType.default, rightSideViewWidth: CGFloat = 44 , rightSideViewHeight: CGFloat = 44, rightMargin: CGFloat = 0, keyboardType: UIKeyboardType = .default, autocorrectionType: UITextAutocorrectionType = .default, autocapitalizationType: UITextAutocapitalizationType = UITextAutocapitalizationType.sentences) {
    self.descriptionLabelText = descriptionLabelText
    self.desriptionLabelDefaultTextColor = desriptionLabelDefaultTextColor
    self.desriptionLabelInvalidTextColor = desriptionLabelInvalidTextColor
    self.textFieldPlaceholder = textFieldPlaceholder
    self.textFieldDefaultTextColor = textFieldDefaultTextColor
    self.textFieldInvalidTextColor = textFieldInvalidTextColor
    self.textFieldDefaultText = textFieldDefaultText
    self.invalidationIcon = invalidationIcon
    self.invalidationErrorMessage = invalidationErrorMessage
    self.returnKeyType = returnKeyType
    self.rightSideViewWidth = rightSideViewWidth
    self.rightSideViewHeight = rightSideViewHeight
    self.keyboardType = keyboardType
    self.autocorrectionType = autocorrectionType
    self.autocapitalizationType = autocapitalizationType
    self.textFieldMinimumHeight = textFieldMinimumHeight
    self.rightMargin = rightMargin
  }
}

class InputField: UIView {
  enum Status {
    case empty
    case valid
    case inValid
  }
  
  let descriptionLabel: UILabel! = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  let textField: UITextField! = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  
  let invalidationButton: UIButton! = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  
  weak var delegate: InputFieldDelegate?
  
  var configuration: InputFieldConfiguration = InputFieldConfiguration() {
    didSet {
      initializeContent()
    }
  }
  
  var status: Status = .empty {
    didSet {
      refreshViewForStatus()
    }
  }
  var validationBlock: ((_ text: String?) -> Bool)? = nil
  var isValid: Bool {
    if let textField = textField,
      let valid = validationBlock?(textField.text) {
      return valid
    } else {
      return true
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    awakeSelf()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    awakeSelf()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    awakeSelf()
  }
  
  func awakeSelf() {
    setupLayout()
    initializeContent()
    applyTheme()
    refreshViewForStatus()
  }
  
  func setupLayout() {
    // Setup basic layout
    self.addSubview(descriptionLabel)
    self.addSubview(textField)
    descriptionLabel.alignLeading("0", trailing: "\(-configuration.rightMargin)", toView: self)
    descriptionLabel.alignTopEdge(withView: self, predicate: "0")
    textField.alignLeading("0", trailing: "0", toView: descriptionLabel)
    textField.constrainTopSpace(toView: descriptionLabel, predicate: "0")
    textField.constrainHeight(">=\(configuration.textFieldMinimumHeight)")
    self.alignBottomEdge(withView: textField, predicate: "0")
    
    // TODO: Remove this later | Only for visualization purposes
    invalidationButton.frame = CGRect(
      x: 0, y: 0, width: configuration.rightSideViewWidth,
      height: configuration.rightSideViewHeight)
    invalidationButton.setBackgroundImage(#imageLiteral(resourceName: "exclamation"), for: .normal)
    invalidationButton.setBackgroundImage(#imageLiteral(resourceName: "exclamation"), for: .highlighted)
    invalidationButton.tintColor = ThemeManager.shared.currentTheme.defaultErrorColor()
    textField.rightView = invalidationButton
    textField.delegate = self
  }
  
  private func initializeContent() {
    descriptionLabel.text = configuration.descriptionLabelText
    textField.placeholder = configuration.textFieldPlaceholder
    textField.text = configuration.textFieldDefaultText
    textField.returnKeyType = configuration.returnKeyType
    textField.keyboardType = configuration.keyboardType
    textField.autocorrectionType = configuration.autocorrectionType
    textField.autocapitalizationType = configuration.autocapitalizationType
    if let textFieldRightImageView = textField.rightView as? UIImageView {
      textFieldRightImageView.image = configuration.invalidationIcon
    }
  }
  
  func refreshViewForStatus() {
    UIView.animate(withDuration: 0.55) { 
      switch self.status {
      case .empty:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightViewMode = UITextFieldViewMode.never
      case .valid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelDefaultTextColor
        self.textField.textColor = self.configuration.textFieldDefaultTextColor
        self.textField.rightViewMode = UITextFieldViewMode.never
      case .inValid:
        self.descriptionLabel.textColor = self.configuration.desriptionLabelInvalidTextColor
        self.textField.textColor = self.configuration.textFieldInvalidTextColor
        self.textField.rightViewMode = UITextFieldViewMode.always
      }
    }
  }
  
  func validateField() -> (isValid: Bool, value: String?, errorMessage: String?) {
    self.textField.resignFirstResponder()
    let valid = isValid
    switch (valid, textField.text?.isEmpty ?? true) {
    case (true, _):
      status = .valid
    case (false, _):
      status = .inValid
    }
    return (isValid, textField.text, configuration.invalidationErrorMessage)
  }
  
  override func becomeFirstResponder() -> Bool {
    return self.textField.becomeFirstResponder()
  }
  
  override func resignFirstResponder() -> Bool {
    return self.textField.resignFirstResponder()
  }
}

extension InputField: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleCaption2(label: descriptionLabel)
    ThemeManager.shared.currentTheme.styleTextField(textField: textField)
  }
}

extension InputField: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // Reset status upon starting editing
    status = .valid
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return delegate?.inputFieldShouldReturn(inputField: self) ?? true
  }
}
