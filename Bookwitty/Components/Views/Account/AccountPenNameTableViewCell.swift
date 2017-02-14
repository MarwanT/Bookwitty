//
//  AccountPenNameTableViewCell.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class AccountPenNameTableViewCell: UITableViewCell {

  static let reuseIdentifier: String = "AccountPenNameTableViewCellReuseIdentifier"

  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: TTTAttributedLabel!
  @IBOutlet weak var disclosureIndicator: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.initializeComponents()
    applyTheme()
  }

  private func initializeComponents() {
    profileImageView.layer.masksToBounds = true
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
  }
}

extension AccountPenNameTableViewCell: Themeable {
  func applyTheme() {
    let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()

    contentView.layoutMargins = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)

    selectedBackgroundView = UIImageView(
      image: UIImage(color: ThemeManager.shared.currentTheme.defaultSelectionColor()))
    tintColor = ThemeManager.shared.currentTheme.defaultTextColor()

    nameLabel.font = FontDynamicType.footnote.font
    nameLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    disclosureIndicator.image = #imageLiteral(resourceName: "rightArrow")
  }
}
