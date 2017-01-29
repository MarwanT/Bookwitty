//
//  InputField.swift
//  Bookwitty
//
//  Created by Marwan  on 1/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class InputField: UIView {
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func awakeAfter(using aDecoder: NSCoder) -> Any? {
    return viewForNibNameIfNeeded(nibName: InputField.defaultNib)
  }
}
