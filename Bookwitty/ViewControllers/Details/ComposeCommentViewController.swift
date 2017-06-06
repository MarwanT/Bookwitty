//
//  ComposeCommentViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ComposeCommentViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    applyTheme()
  }
}

// MARK: - Themeable protocol
extension ComposeCommentViewController: Themeable {
  func applyTheme() {
    contentView.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    textView.textContainerInset = ThemeManager.shared.currentTheme.defaultTextViewInsets()
    textView.layer.cornerRadius = ThemeManager.shared.currentTheme.defaultCornerRadius()
    textView.font = FontDynamicType.body.font
  }
}
