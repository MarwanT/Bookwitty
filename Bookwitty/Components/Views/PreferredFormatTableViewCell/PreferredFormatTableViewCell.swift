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
  
  @IBOutlet weak var primaryLabel: UILabel!
  @IBOutlet weak var secondaryLabel: UILabel!
  @IBOutlet weak var checkmarkImageView: UIImageView!
}
