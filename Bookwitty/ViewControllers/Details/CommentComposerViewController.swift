//
//  CommentComposerViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 6/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol CommentComposerViewControllerDelegate: class {
  func commentComposerCancel(_ viewController: CommentComposerViewController)
  func commentComposerPublish(_ viewController: CommentComposerViewController, content: String?)
}

class CommentComposerViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  fileprivate var parentCommentId: String?
  
  var blurEffectView: UIVisualEffectView?
  
  weak var delegate: CommentComposerViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    applyTheme()
    setupNavigationItems()
    addKeyboardNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textView.becomeFirstResponder()
    self.blurEffectView?.alpha = 1
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.blurEffectView?.alpha = 0
  }
  
  deinit {
    self.blurEffectView?.removeFromSuperview()
  }
  
  func initialize(with parentCommentId: String?) {
    self.parentCommentId = parentCommentId
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
    delegate?.commentComposerCancel(self)
  }
  
  func didTapPublish(_ sender: Any) {
    dismissKeyboard()
    delegate?.commentComposerPublish(self, content: textView.text)
  }
  
  // MARK: - Helpers
  func dismissKeyboard() {
    textView.resignFirstResponder()
  }
  
  func addBlurEffectView(to view: UIView) {
    blurEffectView = UIVisualEffectView()
    blurEffectView?.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
    blurEffectView?.frame = view.bounds
    blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(blurEffectView!)
  }
}

// MARK: - Themeable protocol
extension CommentComposerViewController: Themeable {
  func applyTheme() {
    contentView.layoutMargins = ThemeManager.shared.currentTheme.defaultLayoutMargin()
    textView.textContainerInset = ThemeManager.shared.currentTheme.defaultTextViewInsets()
    textView.layer.cornerRadius = ThemeManager.shared.currentTheme.defaultCornerRadius()
    textView.font = FontDynamicType.body.font
  }
}

// MARK: -
extension CommentComposerViewController {
  class func show(from viewController: UIViewController, delegate: CommentComposerViewControllerDelegate?, parentCommentId: String?) {
    let composeCommentVC = Storyboard.Details.instantiate(CommentComposerViewController.self)
    composeCommentVC.initialize(with: parentCommentId)
    composeCommentVC.delegate = delegate
    composeCommentVC.addBlurEffectView(to: viewController.view)
    
    let navigationController = UINavigationController(rootViewController: composeCommentVC)
    navigationController.modalPresentationStyle = .overCurrentContext
    navigationController.modalTransitionStyle = .crossDissolve
    
    viewController.present(navigationController, animated: true, completion: nil)
    
    return
  }
}
