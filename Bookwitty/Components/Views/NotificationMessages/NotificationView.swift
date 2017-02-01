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

struct NotificationMessage {
  let text: String
}

class NotificationView: MessageView {
  struct StylingConfiguration {
    let backgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultErrorColor()
    let textColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    let image: UIImage? = nil
    let layoutMargin: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
  }
  
  fileprivate var customId: String? = nil
  
  @IBOutlet weak var stackView: UIStackView!
  
  var stylingConfiguration = StylingConfiguration()
  
  var notificationMessages: [NotificationMessage]? = nil {
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
      textLabel.text = notificationMessage.text
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

extension NotificationView {
  static func show(notificationMessages: [NotificationMessage]) {
    let view: NotificationView = try! SwiftMessages.viewFromNib()
    view.notificationMessages = notificationMessages
    view.configureDropShadow()
    var config = SwiftMessages.defaultConfig
    config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
    config.duration = .seconds(seconds: 5)
    config.presentationStyle = .top
    config.dimMode = .none
    SwiftMessages.show(config: config, view: view)
  }
  
  static func hide() {
    SwiftMessages.hide()
  }
}


// MARK: - Identifiable

extension NotificationView {
  override var id: String {
    get {
      return customId ?? generatedID
    }
    set {
      customId = newValue
    }
  }
  
  private var generatedID: String {
    var text = ""
    if let notificationMessages = notificationMessages {
      for notificationMessage in notificationMessages {
        text += notificationMessage.text
      }
    }
    return text
  }
}
