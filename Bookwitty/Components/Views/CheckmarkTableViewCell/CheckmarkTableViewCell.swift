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

  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    applySelectedState()
  }
}


extension CheckmarkTableViewCell: Themeable {
  func applyTheme() {
    titleLabel.font = FontDynamicType.footnote.font
    titleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    backgroundColor = UIColor.clear
  }

  fileprivate func applySelectedState() {
    checkmarkImageView.image = isSelected ? #imageLiteral(resourceName: "tick") : nil
  }
}
