//
//  QuoteEditorViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/26.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol QuoteEditorViewControllerDelegate {
  func quoteEditor(viewController: QuoteEditorViewController, didRequestAdd quote: String, with author: String?)
  func quoteEditorViewControllerDidCancel(_ viewController: QuoteEditorViewController)
}

class QuoteEditorViewController: UIViewController {

  @IBOutlet var quoteTextView: UITextView!
  @IBOutlet var authorTextView: UITextView!
  @IBOutlet var separators: [UIView]!

  fileprivate let viewModel = QuoteEditorViewModel()

  var delegate: QuoteEditorViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()
  }

  fileprivate func initializeComponents() {
    title = Strings.quote()
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    let cancelBarButtonItem = UIBarButtonItem(title: Strings.cancel(),
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelBarButtonTouchUpInside(_:)))

    //TODO: Localize
    let addBarButtonItem = UIBarButtonItem(title: "Add",
                                           style: .plain,
                                           target: self,
                                           action: #selector(addBarButtonTouchUpInside(_:)))

    navigationItem.leftBarButtonItem = cancelBarButtonItem
    navigationItem.rightBarButtonItem = addBarButtonItem

    setTextAppearanceState(of: addBarButtonItem)
    setTextAppearanceState(of: cancelBarButtonItem)
  }

  fileprivate func setTextAppearanceState(of barButtonItem: UIBarButtonItem) -> Void {
    var attributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    attributes[NSForegroundColorAttributeName] = defaultTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .normal)

    let grayedTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    attributes[NSForegroundColorAttributeName] = grayedTextColor
    barButtonItem.setTitleTextAttributes(attributes, for: .disabled)
  }

  @objc fileprivate func cancelBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    delegate?.quoteEditorViewControllerDidCancel(self)
  }

  @objc fileprivate func addBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    let quote: String = quoteTextView.text
    let author: String? = authorTextView.text.isEmpty ? nil : authorTextView.text
    delegate?.quoteEditor(viewController: self, didRequestAdd: quote, with: author)
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

