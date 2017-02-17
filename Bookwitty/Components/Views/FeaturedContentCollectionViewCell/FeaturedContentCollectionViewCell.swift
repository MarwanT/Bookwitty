//
//  FeaturedCollectionViewCell.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class FeaturedContentCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "FeaturedContentCollectionViewCell"
  static let nib = UINib(nibName: reuseIdentifier, bundle: nil)
  
  static let defaultSize = CGSize(width: 150, height: 100)
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
  }
  
  
  // MARK: APIs
  
  var image: UIImage? {
    get {
      return imageView.image
    }
    set (image) {
      imageView.image = image
    }
  }
  
  var title: String? {
    get {
      return label.text
    }
    set (title) {
      label.text = title
    }
  }
}

extension FeaturedContentCollectionViewCell: Themeable {
  func applyTheme() {
    overlayView.backgroundColor = UIColor.bwNero.withAlphaComponent(0.5)
    
    imageView.contentMode = UIViewContentMode.scaleAspectFill
    
    label.font = FontDynamicType.callout.font
    label.textColor = ThemeManager.shared.currentTheme.colorNumber23()
  }
}
