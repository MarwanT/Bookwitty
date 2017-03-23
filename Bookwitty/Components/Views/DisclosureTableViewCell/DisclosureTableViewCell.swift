//
//  DisclosureTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class DisclosureTableViewCell: UITableViewCell {
  static let identifier = "DisclosureTableViewCell"
  static let nib: UINib = UINib(nibName: identifier, bundle: nil)
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var disclosureImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
  }
}

extension DisclosureTableViewCell: Themeable {
  func applyTheme() {
    let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
    
    contentView.layoutMargins = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
    selectedBackgroundView = UIImageView(
      image: UIImage(color: ThemeManager.shared.currentTheme.defaultSelectionColor()))
    tintColor = ThemeManager.shared.currentTheme.defaultTextColor()
    
    label.font = FontDynamicType.caption1.font
    label.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    detailsLabel.font = FontDynamicType.caption2.font
    detailsLabel.textColor = ThemeManager.shared.currentTheme.colorNumber15()
    
    disclosureImageView.image = #imageLiteral(resourceName: "rightArrow")
    disclosureImageView.contentMode = UIViewContentMode.scaleAspectFit
  }
}
