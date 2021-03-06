//
//  TableViewSectionHeaderView.swift
//  Bookwitty
//
//  Created by charles on 2/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TableViewSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "TableViewSectionHeaderViewReuseIdentifier"
  static let nib: UINib = UINib(nibName: "TableViewSectionHeaderView", bundle: nil)

  @IBOutlet weak var label: TTTAttributedLabel!
  @IBOutlet var separators: [UIView]!

  override func awakeFromNib() {
    super.awakeFromNib()

    applyTheme()
  }
}

extension TableViewSectionHeaderView: Themeable {
  func applyTheme() {
    let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()

    contentView.layoutMargins = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)

    label.font = FontDynamicType.footnote.font
    label.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    separators.forEach({ $0.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor() })
  }
}
