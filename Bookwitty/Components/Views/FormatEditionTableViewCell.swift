//
//  FormatEditionTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 7/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class FormatEditionTableViewCell: UITableViewCell {
  static var reuseIdentifier = "FormatEditionTableViewCell"
  
  @IBOutlet weak var leftTextLabel: UILabel!
  @IBOutlet weak var rightTextLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    initializeView()
    applyTheme()
  }
  
  private func initializeView() {
    selectionStyle = .default
  }
}

extension FormatEditionTableViewCell: Themeable {
  func applyTheme() {
    contentView.layoutMargins = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    rightTextLabel.font = FontDynamicType.footnote.font
    rightTextLabel.textColor = ThemeManager.shared.currentTheme.defaultECommerceColor()
    leftTextLabel.font = FontDynamicType.caption1.font
    leftTextLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    separatorInset = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
    
    var backgroundSelectionView: UIView {
      let backView = UIView(frame: CGRect.zero)
      backView.backgroundColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
      return backView
    }
    selectedBackgroundView = backgroundSelectionView
  }
}

