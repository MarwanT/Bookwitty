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

  override func awakeFromNib() {
    super.awakeFromNib()
    self.initializeComponents()
  }
  
  private func initializeComponents() {
    profileImageView.layer.masksToBounds = true
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}
