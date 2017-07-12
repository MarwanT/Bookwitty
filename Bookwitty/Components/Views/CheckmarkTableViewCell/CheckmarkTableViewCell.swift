//
//  CheckmarkTableViewCell.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class CheckmarkTableViewCell: UITableViewCell {
  static let reuseIdentifier = "CheckmarkTableViewCellReuseIdentifier"

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var checkmarkImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    applySelectedState()
  }
}


extension CheckmarkTableViewCell: Themeable {
  func applyTheme() {
    titleLabel.font = FontDynamicType.caption2.font
    titleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    backgroundColor = UIColor.clear
  }

  fileprivate func applySelectedState() {
    let image = isSelected ? #imageLiteral(resourceName: "radioFilled") : #imageLiteral(resourceName: "radioEmpty")
    let color = isSelected ? ThemeManager.shared.currentTheme.defaultButtonColor() : ThemeManager.shared.currentTheme.defaultGrayedTextColor()

    checkmarkImageView.image = image
    checkmarkImageView.tintColor = color
  }
}
