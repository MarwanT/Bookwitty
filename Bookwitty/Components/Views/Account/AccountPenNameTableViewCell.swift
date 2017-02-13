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
  }

  private func initializeComponents() {
    profileImageView.layer.masksToBounds = true
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0

    nameLabel.font = FontDynamicType.footnote.font

    disclosureIndicator.image = #imageLiteral(resourceName: "rightArrow")
  }
}
