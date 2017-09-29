//
//  QuoteEditorViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/26.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class QuoteEditorViewController: UIViewController {

  @IBOutlet var quoteTextView: UITextView!
  @IBOutlet var authorTextView: UITextView!
  @IBOutlet var separators: [UIView]!

  fileprivate let viewModel = QuoteEditorViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    title = Strings.quote()
  }
}

//MARK: - Themable implementation
extension QuoteEditorViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber1()

    view.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    quoteTextView.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    authorTextView.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()

    quoteTextView.textContainerInset = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    authorTextView.textContainerInset = ThemeManager.shared.currentTheme.defaultLayoutMargin()

    separators.forEach({ $0.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()})

    quoteTextView.font = FontDynamicType.title4.font
    quoteTextView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    authorTextView.font = FontDynamicType.caption1.font
    authorTextView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
  }
}

