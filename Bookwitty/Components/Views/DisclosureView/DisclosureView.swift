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
  }
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var disclosureImageView: UIImageView!
  
  weak var delegate: DisclosureViewDelegate? = nil
  
  var style: Style = .normal {
    didSet {
      refreshStyling()
    }
  }
  
  var configuration = Configuration() {
    didSet {
      refreshStyling()
    }
  }
  
  var selected: Bool = false 
  var isAutoDeselectable: Bool = true
  
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
    delegate?.disclosureViewTapped(self)
  }
  
  fileprivate func refreshStyling() {
    let font: UIFont
    
    switch style {
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
    
    refreshStyling()
  }
}
