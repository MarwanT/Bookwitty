//
//  SearchFilterTableViewSectionHeaderView.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SearchFilterTableViewSectionHeaderView: UITableViewHeaderFooterView {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var imageView: UIImageView!

  var selected: Bool = false {
    didSet {
      applySelectedState()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {

  }
}

extension SearchFilterTableViewSectionHeaderView: Themeable {
  func applyTheme() {
    titleLabel.font = FontDynamicType.footnote.font
    titleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    subTitleLabel.font = FontDynamicType.caption1.font
    subTitleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }

  fileprivate func applySelectedState() {
    imageView.image = selected ? #imageLiteral(resourceName: "tick") : nil
  }
}
