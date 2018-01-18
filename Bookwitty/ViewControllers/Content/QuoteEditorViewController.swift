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

  fileprivate let authorPlaceholderLabel = UILabel()
  fileprivate let quotePlaceholderLabel = UILabel()

  fileprivate let viewModel = QuoteEditorViewModel()

  var delegate: QuoteEditorViewControllerDelegate?
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
    setupNavigationBarButtons()
    applyLocalization()
    observeLanguageChanges()
    self.quoteTextView.becomeFirstResponder()
  }

  override func updateViewConstraints() {
    var insets = quoteTextView.textContainerInset
    quotePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    quotePlaceholderLabel.topAnchor.constraint(equalTo: quoteTextView.topAnchor, constant: insets.top).isActive = true
    quotePlaceholderLabel.leftAnchor.constraint(equalTo: quoteTextView.leftAnchor, constant: insets.left + 5).isActive = true

    insets = authorTextView.textContainerInset
    authorPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    authorPlaceholderLabel.topAnchor.constraint(equalTo: authorTextView.topAnchor, constant: insets.top).isActive = true
    authorPlaceholderLabel.leftAnchor.constraint(equalTo: authorTextView.leftAnchor, constant: insets.left + 5).isActive = true

    super.updateViewConstraints()
  }

  fileprivate func initializeComponents() {
    quoteTextView.addSubview(quotePlaceholderLabel)
    quotePlaceholderLabel.text = Strings.quote()
    quoteTextView.delegate = self

    authorTextView.addSubview(authorPlaceholderLabel)
    authorPlaceholderLabel.text = Strings.author()
    authorTextView.delegate = self
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    let cancelBarButtonItem = UIBarButtonItem(title: Strings.cancel(),
                                              style: .plain,
                                              target: self,
                                              action: #selector(cancelBarButtonTouchUpInside(_:)))

    let addBarButtonItem = UIBarButtonItem(title: Strings.add(),
                                           style: .plain,
                                           target: self,
                                           action: #selector(addBarButtonTouchUpInside(_:)))

    addBarButtonItem.isEnabled = self.quoteTextView.text.trimmed.characters.count > 0

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

//MARK: - Localizable implementation
extension QuoteEditorViewController: Localizable {
  func applyLocalization() {
    title = Strings.quote()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

//MARK: - Themable implementation
extension QuoteEditorViewController: Themeable {
  func applyTheme() {
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    view.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    
    var layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    layoutMargins.left = layoutMargins.left - 4
    
    quoteTextView.layoutMargins = layoutMargins
    authorTextView.layoutMargins = layoutMargins

    quoteTextView.textContainerInset = layoutMargins
    authorTextView.textContainerInset = layoutMargins

    separators.forEach({ $0.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()})

    quoteTextView.font = FontDynamicType.title4.font
    quoteTextView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    authorTextView.font = FontDynamicType.caption2.font
    authorTextView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()

    quotePlaceholderLabel.font = FontDynamicType.title4.font
    quotePlaceholderLabel.textColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()

    authorPlaceholderLabel.font = FontDynamicType.caption2.font
    authorPlaceholderLabel.textColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
  }
}

//MARK: - UITextViewDelegate implementation
extension QuoteEditorViewController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    let count = textView.text.characters.count
    setupNavigationBarButtons()
    let alpha: CGFloat = count == 0 ? 1.0 : 0.0
    if textView === quoteTextView {
      quotePlaceholderLabel.alpha = alpha
    } else if textView === authorTextView {
      authorPlaceholderLabel.alpha = alpha
    }
  }
}
