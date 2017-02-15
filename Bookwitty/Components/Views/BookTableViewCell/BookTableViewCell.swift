//
//  BookTableViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
  static let reuseIdentifier = "BookTableViewCell"
  static let nib = UINib(nibName: reuseIdentifier, bundle: nil)
  
  static let minimumHeight: CGFloat = 180
  
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var bookTitleLabel: UILabel!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var productTypeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

extension BookTableViewCell: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme!
    
    bookTitleLabel.font = FontDynamicType.title3.font
    authorNameLabel.font = FontDynamicType.caption1.font
    productTypeLabel.font = FontDynamicType.caption2.font
    priceLabel.font = FontDynamicType.footnote.font
    
    bookTitleLabel.textColor = theme.defaultTextColor()
    authorNameLabel.textColor = theme.defaultTextColor()
    productTypeLabel.textColor = theme.defaultTextColor()
    priceLabel.textColor = theme.defaultECommerceColor()
    
    contentView.layoutMargins = UIEdgeInsets(
      top: theme.generalExternalMargin(),
      left: theme.generalExternalMargin(),
      bottom: theme.generalExternalMargin(),
      right: theme.generalExternalMargin())
    selectedBackgroundView = UIImageView(image: theme.defaultSelectionColor().image())
  }
}
