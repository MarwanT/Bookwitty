//
//  SectionTitleHeaderView.swift
//  Bookwitty
//
//  Created by Marwan  on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SectionTitleHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "SectionTitleHeaderView"
  static let nib = UINib(nibName: reuseIdentifier, bundle: nil)
  
  @IBOutlet weak var verticalBarView: UIView!
  @IBOutlet weak var horizontalBarView: UIView!
  @IBOutlet weak var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
  }
}

extension SectionTitleHeaderView: Themeable {
  func applyTheme() {
  }
}
