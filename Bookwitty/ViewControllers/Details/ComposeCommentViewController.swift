//
//  ComposeCommentViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol ComposeCommentViewControllerDelegate: class {
  func composeCommentCancel(_ viewController: ComposeCommentViewController)
  func composeCommentPublish(_ viewController: ComposeCommentViewController, content: String?)
}

class ComposeCommentViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  weak var delegate: ComposeCommentViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    applyTheme()
    setupNavigationItems()
    addKeyboardNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textView.becomeFirstResponder()
  }
  
  private func setupNavigationItems() {
    let leftBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(didTapCancel(_:)))
    let rightBarButton = UIBarButtonItem(title: Strings.publish(), style: .plain, target: self, action: #selector(didTapPublish(_:)))
    rightBarButton.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    self.navigationItem.leftBarButtonItem = leftBarButton
    self.navigationItem.rightBarButtonItem = rightBarButton
  }
  
  private func addKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  // MARK: - Keyboard Handling
  func keyboardWillShow(_ notification: NSNotification) {
    if let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let frame = value.cgRectValue
      contentViewBottomConstraintToSuperview.constant = -frame.height
    }

    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    contentViewBottomConstraintToSuperview.constant = 0
    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
  
  // MARK: - Action
  func didTapCancel(_ sender: Any) {
    dismissKeyboard()
    delegate?.composeCommentCancel(self)
  }
  
  func didTapPublish(_ sender: Any) {
    dismissKeyboard()
    delegate?.composeCommentPublish(self, content: textView.text)
  }
  
  // MARK: - Helpers
  func dismissKeyboard() {
    textView.resignFirstResponder()
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
