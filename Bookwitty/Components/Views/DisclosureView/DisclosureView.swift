//
//  DisclosureView.swift
//  Bookwitty
//
//  Created by Marwan  on 2/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol DisclosureViewDelegate: class {
  func disclosureViewTapped(_ disclosureView: DisclosureView)
}

class DisclosureView: UIView {
  enum Style {
    case normal
    case highlighted
  }
  
  struct Configuration {
    var normalBackgroundColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    var selectedBackgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
    var isAutoDeselectable: Bool = true
    var style: Style = .normal
  }
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var disclosureImageView: UIImageView!
  
  weak var delegate: DisclosureViewDelegate? = nil
  
  var configuration = Configuration() {
    didSet {
      applyTheme()
    }
  }

  var selected: Bool = false {
    didSet {
      refreshBackground(animated: true) { 
        if self.selected && self.configuration.isAutoDeselectable {
          self.selected = false
        }
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    initializeGestures()
    applyTheme()
  }
  
  func initializeGestures() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnView(_:)))
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  func didTapOnView(_ sender: Any?) {
    selected = !selected
    delegate?.disclosureViewTapped(self)
  }
  
  func refreshBackground(animated: Bool, completion: @escaping () -> Void) {
    let animationDuration: TimeInterval = 0.17
    
    let currentBackgroundColor: UIColor
    switch selected {
    case true:
      currentBackgroundColor = configuration.selectedBackgroundColor
    case false:
      currentBackgroundColor = configuration.normalBackgroundColor
    }
    
    if animated {
      UIView.animate(
        withDuration: animationDuration,
        animations: {
          self.backgroundColor = currentBackgroundColor
      }, completion: { (_) in
          completion()
      })
    } else {
      self.backgroundColor = currentBackgroundColor
      completion()
    }
  }
  
  fileprivate func refreshStyling() {
    let font: UIFont
    
    switch configuration.style {
    case .normal:
      tintColor = ThemeManager.shared.currentTheme.defaultTextColor()
      font = FontDynamicType.caption2.font
    case .highlighted:
      tintColor = ThemeManager.shared.currentTheme.colorNumber19()
      font = FontDynamicType.footnote.font
    }
    
    label.textColor = tintColor
    disclosureImageView.tintColor = tintColor
    label.font = font
  }
}

extension DisclosureView: Themeable {
  func applyTheme() {
    let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
    layoutMargins = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    
    disclosureImageView.image = #imageLiteral(resourceName: "rightArrow")
    disclosureImageView.contentMode = UIViewContentMode.scaleAspectFit
    
    refreshStyling()
    refreshBackground(animated: false, completion: {})
  }
}
