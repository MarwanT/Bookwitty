//
//  BookTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var bookTitleLabel: UILabel!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var productTypeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
