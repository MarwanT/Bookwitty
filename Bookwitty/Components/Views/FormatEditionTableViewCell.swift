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
  }
  
  private func initializeView() {
    selectionStyle = .default
  }
}
