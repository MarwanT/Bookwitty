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
  
  static let minimumHeight: CGFloat = 60
  
  struct Configuration {
    var verticalBarColor: UIColor? = ThemeManager.shared.currentTheme.colorNumber2()
    var horizontalBarColor: UIColor? = ThemeManager.shared.currentTheme.colorNumber2()
  }
  
  @IBOutlet weak var verticalBarView: UIView!
  @IBOutlet weak var horizontalBarView: UIView!
  @IBOutlet weak var label: UILabel!
  
  var configuration = Configuration() {
    didSet {
      applyTheme()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyTheme()
    initializeComponents()
  }
  
  private func initializeComponents() {
    label.numberOfLines = 0
  }
}

extension SectionTitleHeaderView: Themeable {
  func applyTheme() {
    label.font = FontDynamicType.callout.font
    verticalBarView.backgroundColor = configuration.verticalBarColor
    horizontalBarView.backgroundColor = configuration.horizontalBarColor
  }
}
