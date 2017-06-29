//
//  PreferredFormatTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 6/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PreferredFormatTableViewCell: UITableViewCell {
  static let reuseIdentifier = "PreferredFormatTableViewCell"
  static let nib: UINib = UINib(nibName: "PreferredFormatTableViewCell", bundle: nil)
  
  @IBOutlet weak var primaryLabel: UILabel!
  @IBOutlet weak var secondaryLabel: UILabel!
  @IBOutlet weak var checkmarkImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initializeComponents()
  }
  
  private func initializeComponents() {
    let margin = ThemeManager.shared.currentTheme.generalExternalMargin()
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: (margin-10))
  }
  
}
