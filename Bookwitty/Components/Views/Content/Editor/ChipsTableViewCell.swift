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
  
  var configuration = Configuration()

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
    tagsView.tintColor = configuration.tagsTintColor
    tagsView.textColor = configuration.tagsTextColor
    tagsView.selectedColor = configuration.tagsSelectedColor
    tagsView.selectedTextColor = configuration.tagsSelectedTextColor
    tagsView.font = FontDynamicType.caption3.font
    tagsView.padding.left = 0
  }
}

extension ChipsTableViewCell {
  struct Configuration {
    let theme = ThemeManager.shared.currentTheme
    var tagsTintColor: UIColor
    var tagsTextColor: UIColor
    var tagsSelectedColor: UIColor
    var tagsSelectedTextColor: UIColor
    var maximumTags: Int
    var moreTagTitle: String
    var moreTagBackgroundColor: UIColor
    var moreTagBorderColor: UIColor
    var moreTagTextColor: UIColor
    
    init() {
      tagsTintColor = theme.colorNumber9()
      tagsTextColor = theme.colorNumber20()
      tagsSelectedColor = theme.colorNumber25()
      tagsSelectedTextColor = theme.colorNumber23()
      maximumTags = 4
      moreTagTitle = Strings.more()
      moreTagBackgroundColor = UIColor.white
      moreTagBorderColor = theme.colorNumber25()
      moreTagTextColor = theme.colorNumber25()
    }
  }
}
