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
  func commentComposerWillBeginPublishingComment(_ viewController: CommentComposerViewController)
  func commentComposerDidFinishPublishingComment(_ viewController: CommentComposerViewController, success: Bool, comment: Comment?, resource: ModelCommonProperties?)
}

class CommentComposerViewController: UIViewController {
  @IBOutlet weak var resourcePresenterLabel: UILabel!
  @IBOutlet weak var resourceTitleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var separatorView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  @IBOutlet weak var separatorTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var separatorBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewLeadingToImageViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var resourceTitleLabelTopConstraint: NSLayoutConstraint!
  
  fileprivate let textViewPlaceholderLabel = UILabel()
  
  fileprivate var viewModel = CommentComposerViewModel()
  
  weak var delegate: CommentComposerViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    applyTheme()
    initialize()
    setupContent()
    setupNavigationItems()
    addKeyboardNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textView.becomeFirstResponder()
  }
  
  override func updateViewConstraints() {
    separatorTopConstraint.constant = 15
    separatorBottomConstraint.constant = 15
    textViewLeadingToImageViewTrailingConstraint.constant = 10
    resourceTitleLabelTopConstraint.constant = 2
    
    let insets = textView.textContainerInset
    textViewPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    textViewPlaceholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: -2.5).isActive = true
    textViewPlaceholderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: insets.left + 5).isActive = true
    
    super.updateViewConstraints()
  }
  
  func initialize(with resource: ModelCommonProperties, parentCommentIdentifier: String?) {
    viewModel.initialize(with: resource, parentCommentIdentifier: parentCommentIdentifier)
  }
  
  private func initialize() {
    textView.addSubview(textViewPlaceholderLabel)
    textViewPlaceholderLabel.text = Strings.write_a_comment()
    textView.delegate = self
    textViewPlaceholderLabel.constrainHeight(toView: imageView, predicate: "0")
  }
  
  private func setupContent() {
    resourcePresenterLabel.text = viewModel.resourceTitlePresenterText
    resourceTitleLabel.text = viewModel.resourceExcerpt
    imageView.sd_setImage(
      with: viewModel.penNameImageURL,
      placeholderImage: ThemeManager.shared.currentTheme.penNamePlaceholder)
    updateTextViewContentInsetIfNeeded()
  }
  
  private func setupNavigationItems() {
    let leftBarButton = UIBarButtonItem(title: Strings.cancel(), style: .plain, target: self, action: #selector(didTapCancel(_:)))
    let rightBarButton = UIBarButtonItem(title: Strings.post(), style: .plain, target: self, action: #selector(didTapPublish(_:)))
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
    guard publishComment() else {
      return
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resource else { return }
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
  
  func publishComment() -> Bool {
    guard let text = textView.text, !text.isEmpty else {
      return false
    }
    
    delegate?.commentComposerWillBeginPublishingComment(self)
    viewModel.publishComment(text: text) { (success, comment, error) in
      if !success, let error = error {
        self.showAlertWith(
        title: error.title ?? "", message: error.message ?? "") { _ in
          _ = self.becomeFirstResponder()
        }
      }
      self.delegate?.commentComposerDidFinishPublishingComment(
        self, success: success, comment: comment, resource: self.viewModel.resource)
    }
    return true
  }
  
  // MARK: - Helpers
  func dismissKeyboard() {
    textView.resignFirstResponder()
  }
}

// MARK: - Themeable protocol
extension CommentComposerViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    contentView.layoutMargins = UIEdgeInsets(top: 15, left: 17, bottom: 10, right: 17)
    textView.textContainerInset = UIEdgeInsets.zero
    textView.layer.cornerRadius = theme.defaultCornerRadius()
    textView.font = FontDynamicType.Reference.type17.font
    resourcePresenterLabel.font = FontDynamicType.Reference.type10.font
    resourceTitleLabel.font = FontDynamicType.Reference.type9.font
    textView.textColor = theme.defaultTextColor()
    resourcePresenterLabel.textColor = theme.defaultGrayedTextColor()
    resourceTitleLabel.textColor = theme.defaultTextColor()
    separatorView.backgroundColor = theme.defaultSeparatorColor()
    imageView.setRoundedCornersWithRadius(imageView.frame.height/2, width: 0, color: nil)
    textViewPlaceholderLabel.textColor = theme.defaultGrayedTextColor()
    textViewPlaceholderLabel.font = FontDynamicType.Reference.type17.font
  }
}

// MARK: - Text View Delegate
extension CommentComposerViewController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    updateTextViewContentInsetIfNeeded()
    
    let count = textView.text.count
    let alpha: CGFloat = count == 0 ? 1.0 : 0.0
    textViewPlaceholderLabel.alpha = alpha
  }
  
  fileprivate func updateTextViewContentInsetIfNeeded() {
    var topInsetValue: CGFloat = 12
    if let font = textView.font {
      let numberOfLines = floor(textView.contentSize.height / font.lineHeight)
      if numberOfLines > 1 {
        if textView.textContainerInset.top != 0 {
          textView.textContainerInset.top = 0
        }
      } else {
        if textView.textContainerInset.top != topInsetValue {
          textView.textContainerInset.top = topInsetValue
        }
      }
    } else {
      textView.textContainerInset.top = topInsetValue
    }
  }
}

// MARK: -
extension CommentComposerViewController {
  class func show(from viewController: UIViewController, delegate: CommentComposerViewControllerDelegate?, resource: ModelCommonProperties, parentCommentIdentifier: String?) {
    let composeCommentVC = Storyboard.Details.instantiate(CommentComposerViewController.self)
    composeCommentVC.initialize(with: resource, parentCommentIdentifier: parentCommentIdentifier)
    composeCommentVC.delegate = delegate
    
    let navigationController = UINavigationController(rootViewController: composeCommentVC)
    navigationController.modalPresentationStyle = .overCurrentContext
    navigationController.modalTransitionStyle = .crossDissolve
    
    viewController.present(navigationController, animated: true, completion: nil)
  }
}
