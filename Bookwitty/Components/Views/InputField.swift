//
//  InputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

struct InputFieldConfiguration {
  var descriptionLabelText: String? = nil
  var desriptionLabelDefaultTextColor: UIColor = UIColor.black
  var desriptionLabelInvalidTextColor: UIColor = UIColor.red
  var textFieldPlaceholder: String? = nil
  var textFieldDefaultTextColor: UIColor = UIColor.black
  var textFieldInvalidTextColor: UIColor = UIColor.red
  var textFieldDefaultText: String? = nil
  var invalidationIcon: UIImage? = nil
}

class InputField: UIView {
  enum Status {
    case empty
    case valid
    case inValid
  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  
  var configuration: InputFieldConfiguration = InputFieldConfiguration() {
    didSet {
      initializeContent()
    }
  }
  
  var status: Status = .empty 
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupLayout()
    initializeContent()
    applyTheme()
    refreshViewForStatus()
  }
  
  override func awakeAfter(using aDecoder: NSCoder) -> Any? {
    return viewForNibNameIfNeeded(nibName: InputField.defaultNib)
  }
  
  private func setupLayout() {
    let textFieldRightView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    // TODO: Remove this later | Only for visualization purposes
    textFieldRightView.backgroundColor = UIColor.red
    textField.rightView = textFieldRightView
  }
  
  private func initializeContent() {
    descriptionLabel.text = configuration.descriptionLabelText
    textField.placeholder = configuration.textFieldPlaceholder
    textField.text = configuration.textFieldDefaultText
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
}

extension InputField: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleLabel(label: descriptionLabel)
    ThemeManager.shared.currentTheme.styleTextField(textField: textField)
    configuration.desriptionLabelDefaultTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    configuration.desriptionLabelInvalidTextColor = ThemeManager.shared.currentTheme.colorNumber19()
    
    if let textFieldRightImageView = textField.rightView as? UIImageView {
      textFieldRightImageView.image = configuration.invalidationIcon
    }
  }
}
