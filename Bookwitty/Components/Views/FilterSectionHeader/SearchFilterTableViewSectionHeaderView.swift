//
//  SearchFilterTableViewSectionHeaderView.swift
//  Bookwitty
//
//  Created by charles on 5/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SearchFilterTableViewSectionHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "SearchFilterTableViewSectionHeaderViewReuseIdentifier"
  static let nib: UINib = UINib(nibName: "SearchFilterTableViewSectionHeaderView", bundle: nil)

  enum Mode {
    case collapsed
    case expanded

    mutating func toggle() {
      switch self {
      case .collapsed:
        self = .expanded
      case .expanded:
        self = .collapsed
      }
    }
  }

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var separatorView: UIView!

  fileprivate var mode: Mode = .collapsed

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
    contentView.backgroundColor = UIColor.white
    titleLabel.font = FontDynamicType.footnote.font
    titleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    subTitleLabel.font = FontDynamicType.caption1.font
    subTitleLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    separatorView.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: 0.0)
  }
}
