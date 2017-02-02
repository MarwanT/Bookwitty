//
//  PenNameViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class PenNameViewController: UIViewController {
  @IBOutlet weak var circularView: UIView!
  @IBOutlet weak var plusImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
  }
}

extension PenNameViewController: Themeable {
  func applyTheme() {
    circularView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber11()
    makeViewCircular(view: circularView, borderColor: ThemeManager.shared.currentTheme.colorNumber18(), borderWidth: 1.0)
  }

  func makeViewCircular(view: UIView,borderColor: UIColor, borderWidth: CGFloat) {
    view.layer.cornerRadius = view.frame.size.width/2
    view.clipsToBounds = true
    view.layer.borderColor = borderColor.cgColor
    view.layer.borderWidth = 1.0
  }
}
