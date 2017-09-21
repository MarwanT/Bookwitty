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
  func commentComposerPublish(_ viewController: CommentComposerViewController, content: String?, postId: String?, parentCommentId: String?)
}

class CommentComposerViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  fileprivate var parentCommentId: String?
  fileprivate var postId: String?
  
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
  }
  
  func initialize(with postId: String?, parentCommentId: String?) {
    self.postId = postId
    self.parentCommentId = parentCommentId
  }
  
  private func setupNavigationItems() {
    let leftBarButton = UIBarButtonItem(title: Strings.cancel(), style: .plain, target: self, action: #selector(didTapCancel(_:)))
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
  
  override func becomeFirstResponder() -> Bool {
    return textView.becomeFirstResponder()
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
    delegate?.commentComposerPublish(self, content: textView.text, postId: postId, parentCommentId: parentCommentId)

    //MARK: [Analytics] Event
    guard let resource = (DataManager.shared.fetchResource(with: postId ?? "") as? ModelCommonProperties) else { return }
    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: .PublishComment,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
  
  // MARK: - Helpers
  func dismissKeyboard() {
    textView.resignFirstResponder()
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
  class func show(from viewController: UIViewController, delegate: CommentComposerViewControllerDelegate?, postId: String?, parentCommentId: String?) {
    let composeCommentVC = Storyboard.Details.instantiate(CommentComposerViewController.self)
    composeCommentVC.initialize(with: postId, parentCommentId: parentCommentId)
    composeCommentVC.delegate = delegate
    
    let navigationController = UINavigationController(rootViewController: composeCommentVC)
    navigationController.modalPresentationStyle = .overCurrentContext
    navigationController.modalTransitionStyle = .crossDissolve
    
    viewController.present(navigationController, animated: true, completion: nil)
  }
}
