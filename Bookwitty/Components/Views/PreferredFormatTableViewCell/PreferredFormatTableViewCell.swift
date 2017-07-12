//
//  PreferredFormatTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 6/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PreferredFormatTableViewCell: UITableViewCell {
  static let reuseIdentifier = "PreferredFormatTableViewCell"
  static let nib: UINib = UINib(nibName: "PreferredFormatTableViewCell", bundle: nil)
  
  @IBOutlet weak var primaryLabel: UILabel!
  @IBOutlet weak var secondaryLabel: UILabel!
  @IBOutlet weak var checkmarkImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initializeComponents()
    applyTheme()
  }
  
  private func initializeComponents() {
    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: 0)
    
    selectionStyle = .none
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    applySelectedState()
  }
}

extension PreferredFormatTableViewCell: Themeable {
  func applyTheme() {
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    primaryLabel.font = FontDynamicType.caption1.font
    primaryLabel.textColor = defaultTextColor
    secondaryLabel.font = FontDynamicType.caption2.font
    secondaryLabel.textColor = defaultTextColor
    contentView.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    backgroundColor = UIColor.clear
  }
  
  fileprivate func applySelectedState() {
    let image = isSelected ? #imageLiteral(resourceName: "radioFilled") : #imageLiteral(resourceName: "radioEmpty")
    let color = isSelected ? ThemeManager.shared.currentTheme.defaultButtonColor() : ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    let textColor = isSelected ? ThemeManager.shared.currentTheme.defaultECommerceColor() : ThemeManager.shared.currentTheme.defaultTextColor()
    let textFont = isSelected ? FontDynamicType.footnote.font : FontDynamicType.caption1.font
    
    secondaryLabel.font = textFont
    secondaryLabel.textColor = textColor
    checkmarkImageView.image = image
    checkmarkImageView.tintColor = color
  }
}
