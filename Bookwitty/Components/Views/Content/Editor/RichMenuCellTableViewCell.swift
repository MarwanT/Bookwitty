//
//  RichMenuCellTableViewCell.swift
//  Bookwitty
//
//  Created by ibrahim on 9/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RichMenuCellTableViewCell: UITableViewCell {

  static let identifier = "RichMenuCellTableViewCellReuseIdentifier"
  @IBOutlet weak var menuImageView: UIImageView!
  @IBOutlet weak var menuLabel: UILabel!
}

extension RichMenuCellTableViewCell: Themeable {
  func applyTheme() {
  }
}
