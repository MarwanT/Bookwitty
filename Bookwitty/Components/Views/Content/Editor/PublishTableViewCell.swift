//
//  PulishTableViewCell.swift
//  Bookwitty
//
//  Created by ibrahim on 10/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

final class PublishTableViewCell: UITableViewCell {
  @IBOutlet weak var cellImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var cellLabel: UILabel!
  @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
  static let identifier: String = "PublishTableViewCellReuseIdentifier"
  static let height: CGFloat = 44.0
  override func awakeFromNib() {
    super.awakeFromNib()
    self.initializeComponents()
    applyTheme()
  }
  
  private func initializeComponents() {
    profileImageView.layer.masksToBounds = true
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

extension PublishTableViewCell: Themeable {
  
  func applyTheme() {
    
    selectedBackgroundView = UIImageView(
      image: UIImage(color: ThemeManager.shared.currentTheme.defaultSelectionColor()))
    tintColor = ThemeManager.shared.currentTheme.defaultTextColor()

    userNameLabel.font = FontDynamicType.caption1.font
    userNameLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    cellLabel.font = FontDynamicType.caption1.font
    cellLabel.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    
    disclosureIndicatorImageView.image = #imageLiteral(resourceName: "rightArrow")
  }
}
