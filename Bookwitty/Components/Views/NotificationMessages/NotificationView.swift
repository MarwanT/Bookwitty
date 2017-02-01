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
  
  var notificationMessages: [String]? = nil {
    didSet {
      refreshLayout()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    refreshLayout()
  }
  
  func refreshLayout() {
    guard let stackView = stackView, let notificationMessages = notificationMessages else {
      return
    }
    
    backgroundColor = stylingConfiguration.backgroundColor
    stackView.layoutMargins = stylingConfiguration.layoutMargin
    stackView.isLayoutMarginsRelativeArrangement = true
    
    for notificationMessage in notificationMessages {
      let imageView = UIImageView(image: stylingConfiguration.image)
      imageView.tintColor = stylingConfiguration.imageTintColor
      imageView.backgroundColor = UIColor.orange
      imageView.constrainWidth("30")
      imageView.constrainHeight("30")
  
      let textLabel = UILabel(frame: CGRect.zero)
      ThemeManager.shared.currentTheme.styleLabel(label: textLabel)
      textLabel.textColor = stylingConfiguration.textColor
      textLabel.text = notificationMessage
      textLabel.numberOfLines = 0
      textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
      let horizontalStackView = UIStackView(arrangedSubviews: [imageView, textLabel])
      horizontalStackView.axis = UILayoutConstraintAxis.horizontal
      horizontalStackView.spacing = 10
      horizontalStackView.alignment = UIStackViewAlignment.top
      stackView.addArrangedSubview(horizontalStackView)
      textLabel.sizeToFit()
      self.layoutIfNeeded()
    }
  }
}
