//
//  UniColorSectionHeaderView.swift
//  Bookwitty
//
//  Created by Marwan  on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class UniColorSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "UniColorSectionHeaderView"
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    applyTheme()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UniColorSectionHeaderView: Themeable {
  func applyTheme() {
    textLabel?.font = FontDynamicType.subheadline.font
    textLabel?.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    contentView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}
