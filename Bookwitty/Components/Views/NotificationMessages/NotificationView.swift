//
//  ErrorNotificationView.swift
//  Bookwitty
//
//  Created by Marwan  on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import SwiftMessages
import FLKAutoLayout

class NotificationView: MessageView {
  struct StylingConfiguration {
    let backgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultErrorColor()
    let textColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    let image: UIImage? = nil
    let layoutMargin: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
  }
  
  @IBOutlet weak var stackView: UIStackView!
  
  var stylingConfiguration = StylingConfiguration()
}
