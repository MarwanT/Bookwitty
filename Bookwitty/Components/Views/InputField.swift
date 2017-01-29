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
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  
  var configuration: InputFieldConfiguration = InputFieldConfiguration()
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func awakeAfter(using aDecoder: NSCoder) -> Any? {
    return viewForNibNameIfNeeded(nibName: InputField.defaultNib)
  }
}
