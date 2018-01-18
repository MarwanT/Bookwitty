//
//  ChipsTableViewCell.swift
//  Bookwitty
//
//  Created by ibrahim on 10/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField
class ChipsTableViewCell: UITableViewCell {
  @IBOutlet weak var cellImageView: UIImageView!
  @IBOutlet weak var tagsView: WSTagsField!

  static let identifier = "ChipsTableViewCellReuseableIdentifier"
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
    tagsView.readOnly = true
  }
  
  func setTags(_ tags:[String])  {
    tags.forEach { tagsView.addTag($0) }
  }
}

extension ChipsTableViewCell: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    tagsView.tintColor = theme.colorNumber9()
    tagsView.textColor = theme.colorNumber20()
    tagsView.selectedColor = theme.colorNumber25()
    tagsView.selectedTextColor = theme.colorNumber23()
    tagsView.font = FontDynamicType.caption3.font
    tagsView.padding.left = 0
  }
}
