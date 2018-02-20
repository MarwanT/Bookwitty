//
//  RichMenuCellTableViewCell.swift
//  Bookwitty
//
//  Created by ibrahim on 9/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RichMenuCellTableViewCell: UITableViewCell {

  static let identifier = "RichMenuCellTableViewCellReuseIdentifier"
  @IBOutlet weak var menuImageView: UIImageView!
  @IBOutlet weak var menuLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
  }
}

extension RichMenuCellTableViewCell: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    menuLabel.font = FontDynamicType.caption1.font
    menuLabel.textColor = theme.defaultTextColor()
    menuImageView.tintColor = theme.colorNumber20()
  }
}
