//
//  ContentEditorViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import RichEditorView
import Moya

class ContentEditorViewController: UIViewController {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  @IBOutlet weak var editorView: RichEditorView!

  @IBOutlet weak var titleTextField: UITextField!

  fileprivate var currentRequest: Cancellable?
  let viewModel = ContentEditorViewModel()
  
  private var timer: Timer!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()
    loadNavigationBarButtons()
    addKeyboardNotifications()
    self.titleTextField.addTarget(self, action: #selector(ContentEditorViewController.textChanged(_:)), for: .editingChanged)
  }
  
  @objc private func textChanged(_ sender: UITextField) {
    self.viewModel.currentPost?.title = sender.text
  }
  
  private func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    let redColor = ThemeManager.shared.currentTheme.colorNumber19()
    
    let closeBarButtonItem = UIBarButtonItem(title: Strings.close(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.closeBarButtonTouchUpInside(_:)))
    
    closeBarButtonItem.setTitleTextAttributes([
      NSFontAttributeName: FontDynamicType.caption1.font,
      NSForegroundColorAttributeName : redColor], for: UIControlState.normal)
    
    let draftsBarButtonItem = UIBarButtonItem(title: Strings.drafts(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(self.draftsBarButtonTouchUpInside(_:)))
    
    draftsBarButtonItem.setTitleTextAttributes([
      NSFontAttributeName: FontDynamicType.caption1.font,
      NSForegroundColorAttributeName : redColor], for: UIControlState.normal)
    
    let imageSize = CGSize(width: 28.0, height: 28.0)
    
    let plusBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").imageWithSize(size: imageSize),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.plusBarButtonTouchUpInside(_:)))
    
    let nextBarButtonItem = UIBarButtonItem(title: Strings.next(),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.nextBarButtonTouchUpInside(_:)))
    
    let size: CGFloat = 44.0
    
    let undoButton = UIButton(type: .custom)
    undoButton.setImage(#imageLiteral(resourceName: "undo"), for: .normal)
    undoButton.translatesAutoresizingMaskIntoConstraints = false
    undoButton.addWidthConstraint(size)
    undoButton.addHeightConstraint(size)
    undoButton.addTarget(self, action: #selector(self.undoButtonTouchUpInside(_:)), for: .touchUpInside)
    
    let redoButton = UIButton(type: .custom)
    redoButton.setImage(#imageLiteral(resourceName: "redo"), for: .normal)
    redoButton.translatesAutoresizingMaskIntoConstraints = false
    redoButton.addWidthConstraint(size)
    redoButton.addHeightConstraint(size)
    redoButton.addTarget(self, action: #selector(self.redoButtonTouchUpInside(_:)), for: .touchUpInside)

    let stackView = UIStackView(frame: .zero)
    stackView.spacing = 5
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.axis = .horizontal
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(undoButton)
    stackView.addArrangedSubview(redoButton)
    
    navigationItem.titleView = stackView
    
    let leftBarButtonItems = [closeBarButtonItem, draftsBarButtonItem]
    let rightBarButtonItems = [nextBarButtonItem, plusBarButtonItem]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
  
  // MARK: - Navigation items actions
  @objc private func undoButtonTouchUpInside(_ sender: UIButton) {
    guard let toolbar = editorView.inputAccessoryView as? RichEditorToolbar else {
      return
    }
    ContentEditorOption.undo.action(toolbar)
  }
  
  @objc private func redoButtonTouchUpInside(_ sender: UIButton) {
    guard let toolbar = editorView.inputAccessoryView as? RichEditorToolbar else {
      return
    }
    ContentEditorOption.redo.action(toolbar)
  }
  
  @objc private func closeBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func draftsBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    //Todo: Implementation
  }
  
  @objc private func plusBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    let richContentMenuViewController = Storyboard.Content.instantiate(RichContentMenuViewController.self)
    richContentMenuViewController.delegate = self
    self.definesPresentationContext = true
    richContentMenuViewController.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber20().withAlphaComponent(0.5)
    richContentMenuViewController.modalPresentationStyle = .overCurrentContext
    
    self.navigationController?.present(richContentMenuViewController, animated: true, completion: nil)
  }
  
  @objc private func nextBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    
    self.saveAsDraft()
    
    let publishMenuViewController = Storyboard.Content.instantiate(PublishMenuViewController.self)
    publishMenuViewController.delegate = self
    publishMenuViewController.viewModel.initialize(with: self.viewModel.linkedTags, linkedTopics: self.viewModel.linkedTopics)
    self.definesPresentationContext = true
    publishMenuViewController.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber20().withAlphaComponent(0.5)
    publishMenuViewController.modalPresentationStyle = .overCurrentContext
    
    self.navigationController?.present(publishMenuViewController, animated: true, completion: nil)
  }
  
  @objc private func toggleEnableState(of barButtonItem: UIBarButtonItem) -> Void {
    barButtonItem.isEnabled = !barButtonItem.isEnabled
  }
  
  @objc private func toggleTextAppearanceState(of barButtonItem:UIBarButtonItem) -> Void {
    toggleEnableState(of:barButtonItem)
    var oldAttributes = barButtonItem.titleTextAttributes(for: .normal) ?? [:]

    if barButtonItem.isEnabled {
      let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
      oldAttributes[NSForegroundColorAttributeName] = defaultTextColor
      barButtonItem.setTitleTextAttributes(oldAttributes, for: .normal)
    } else {
      let grayedTextColor = ThemeManager.shared.currentTheme.defaultGrayedTextColor()
      oldAttributes[NSForegroundColorAttributeName] = grayedTextColor
      barButtonItem.setTitleTextAttributes(oldAttributes, for: .normal)
    }
  }
  
  func showAddLinkAlertView() {
    
    let alertController = UIAlertController(title: Strings.addLink(), message: "", preferredStyle: .alert)
    alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
      textField.placeholder = "http://"
    })
    let confirmAction = UIAlertAction(title: Strings.ok(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
      
      guard let toolbar = self.editorView.inputAccessoryView as? RichEditorToolbar else {
          return
        }
      ContentEditorOption.link.action(toolbar)
    })
    alertController.addAction(confirmAction)
    
    let cancelAction = UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }

  // MARK: - RichEditor
  private func initializeComponents() {
    editorView.placeholder = Strings.write_here()
    setupEditorToolbar()
    
    self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ContentEditorViewController.tick), userInfo: nil, repeats: true)
    self.timer.tolerance = 0.5
  }
  
  private func createContent() {
    let html = "<p>Hello0</p>"
    _ = PublishAPI.createContent(title: self.titleTextField.text ?? "", body: html) { (success, candidatePost, error) in
      
      guard success, let candidatePost = candidatePost else {
        return
      }
      self.viewModel.set(candidatePost)
    }
  }
  
  fileprivate func updateContent(with title: String?, body: String?, imageURL: String?, shortDescription: String?) {
    guard let id = self.viewModel.currentPost.id else {
      return
    }
    _ = PublishAPI.updateContent(id: id, title: title, body: body, imageURL: imageURL, shortDescription: shortDescription, completion: { (success, candidatePost, error) in
      guard success, let candidatePost = candidatePost else {
        return
      }
      self.viewModel.set(candidatePost)
    })
  }
  
  private func dispatchContent() {
    
    let newHashValue = self.viewModel.currentPost.hash
    let latestHashValue = self.viewModel.latestHashValue    
    let body = "<p>Hello0</p>"
    
    if self.viewModel.currentPost.id == nil {
      self.createContent()
    } else if newHashValue != latestHashValue {
      self.updateContent(with: title, body: body, imageURL: self.viewModel.currentPost.imageUrl, shortDescription: self.viewModel.currentPost.shortDescription)
    }

  }
  
  @objc private func tick() {
    dispatchContent()
  }
  
  private func setupEditorToolbar() {
    let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
    toolbar.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    toolbar.options = ContentEditorOption.toolbarOptions
    toolbar.editor = editorView // Previously instantiated RichEditorView
    toolbar.delegate = self
    editorView.inputAccessoryView = toolbar
  }

  // MARK: - Keyboard Handling
  private func addKeyboardNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(_:)),
                                           name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(_:)),
                                           name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
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
  
  // MARK: - User Import Action(s) Handling
  func presentImagePicker(with source: UIImagePickerControllerSourceType) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = source
    imagePickerController.allowsEditing = true
    self.navigationController?.present(imagePickerController, animated: true, completion: nil)
  }

  func presentRichBookViewController() {
    let richBookViewController = RichBookViewController()
    richBookViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: richBookViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  func presentRichLinkViewController(with mode: RichLinkPreviewViewController.Mode) {
    let controller = Storyboard.Content.instantiate(RichLinkPreviewViewController.self)
    controller.mode = mode
    controller.delegate = self
    let navigationController = UINavigationController(rootViewController: controller)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  fileprivate func presentQuoteEditorViewController() {
    let controller = Storyboard.Content.instantiate(QuoteEditorViewController.self)
    controller.delegate = self
    let navigationController = UINavigationController(rootViewController: controller)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
}

extension ContentEditorViewController: RichEditorToolbarDelegate {
  
  func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    self.showAddLinkAlertView()
  }
}

extension ContentEditorViewController : RichContentMenuViewControllerDelegate {
  
  func richContentMenuViewControllerDidCancel(_ richContentMenuViewController: RichContentMenuViewController) {
    richContentMenuViewController.dismiss(animated: true, completion: nil)
  }
  
  func richContentMenuViewController(_ richContentMenuViewController: RichContentMenuViewController, didSelect item: RichContentMenuViewController.Item) {
    richContentMenuViewController.dismiss(animated: true, completion: nil)
    switch item {
    case .imageCamera:
      self.presentImagePicker(with: .camera)
    case .imageLibrary:
      self.presentImagePicker(with: .photoLibrary)
    case .link:
      self.presentRichLinkViewController(with: .link)
    case .book:
      self.presentRichBookViewController()
    case .video:
      self.presentRichLinkViewController(with: .video)
    case .audio:
      self.presentRichLinkViewController(with: .audio)
    case .quote:
      self.presentQuoteEditorViewController()
    }
  }
}

extension ContentEditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }

    self.navigationController?.dismiss(animated: true, completion: nil)

    viewModel.upload(image: image) {
      (success: Bool, link: String?) in
      //TODO: Send to JS
    }
  }
}

extension ContentEditorViewController: RichBookViewControllerDelegate {
  func richBookViewController(_ richBookViewController: RichBookViewController, didSelect book: Book) {
    self.navigationController?.dismiss(animated: true, completion: nil)
    //TODO: Send to JS
  }
}

extension ContentEditorViewController: RichLinkPreviewViewControllerDelegate {
  func richLinkPreview(viewController: RichLinkPreviewViewController, didRequestLinkAdd: URL, with response: Response) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
    //TODO: Sendt to JS
  }

  func richLinkPreviewViewControllerDidCancel(_ viewController: RichLinkPreviewViewController) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController: QuoteEditorViewControllerDelegate {
  func quoteEditor(viewController: QuoteEditorViewController, didRequestAdd quote: String, with author: String?) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
    //TODO: Sendt to JS
  }

  func quoteEditorViewControllerDidCancel(_ viewController: QuoteEditorViewController) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController {
  func presentTagsViewController() {
    guard let currentPost = self.viewModel.currentPost, let currentPostId = currentPost.id else {
      return
    }
    
    let linkTagsViewController = Storyboard.Content.instantiate(LinkTagsViewController.self)
    linkTagsViewController.viewModel.initialize(with: currentPostId, linkedTags: self.viewModel.linkedTags)
    linkTagsViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: linkTagsViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  func presentLinkTopicsViewController() {
    guard let currentPost = self.viewModel.currentPost, let currentPostId = currentPost.id else {
      return
    }
    
    let linkTopicsViewController = Storyboard.Content.instantiate(LinkTopicsViewController.self)
    linkTopicsViewController.viewModel.initialize(with: currentPostId, linkedTopics: self.viewModel.linkedTopics)
    linkTopicsViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: linkTopicsViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
  func presentPostPreviewViewController() {
    guard let currentPost = self.viewModel.currentPost else {
      return
    }
    
    let postPreviewViewController = PostPreviewViewController()
    postPreviewViewController.viewModel.initialize(with: currentPost)
    postPreviewViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: postPreviewViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
  func publishYourPost() {
    
    guard let currentPost = self.viewModel.currentPost, let currentPostId = currentPost.id else {
      return
    }
    
    _ = PublishAPI.updateContent(id: currentPostId, title: self.viewModel.currentPost.title, body: self.viewModel.currentPost.body, imageURL: self.viewModel.currentPost.imageUrl, shortDescription: self.viewModel.currentPost.shortDescription, status: .public, completion: { (success, post, error) in
      guard success else {
        return
      }
    })
  }
}

extension ContentEditorViewController {
  func saveAsDraft() {
    //Ask the content editor for the body.
    let html = "<p>Hello</p>"
   self.updateContent(with: self.titleTextField.text, body: html, imageURL: self.viewModel.currentPost.imageUrl, shortDescription: self.viewModel.currentPost.shortDescription)
  }
}

extension ContentEditorViewController: PublishMenuViewControllerDelegate {
  
  func publishMenu(_ viewController: PublishMenuViewController, didSelect item: PublishMenuViewController.Item) {
    viewController.dismiss(animated: true, completion: nil)
    
    switch item {
    case .penName:
      break
    case .linkTopics:
      self.presentLinkTopicsViewController()
    case .addTags:
      self.presentTagsViewController()
    case .postPreview:
      self.presentPostPreviewViewController()
    case .publishYourPost:
      self.publishYourPost()
    case .saveAsDraft:
      self.saveAsDraft()
    case .goBack:
      break
    }
  }
}

extension ContentEditorViewController: LinkTagsViewControllerDelegate {
  func linkTags(viewController: LinkTagsViewController, didLink tags:[Tag]) {
    self.viewModel.linkedTags = tags
    viewController.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController: LinkTopicsViewControllerDelegate {
  func linkTopics(viewController: LinkTopicsViewController, didLink topics: [Topic]) {
    self.viewModel.linkedTopics = topics
    viewController.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController: PostPreviewViewControllerDelegate {
  func postPreview(viewController: PostPreviewViewController, didFinishPreviewing post: CandidatePost) {
    self.updateContent(with: post.title, body: post.body, imageURL: post.imageUrl, shortDescription: post.shortDescription)
  }
}

extension ContentEditorViewController: PenNameViewControllerDelegate {
  func penName(viewController: PenNameViewController, didFinish: PenNameViewController.Mode, with penName: PenName?) {
    
    switch didFinish {
    case .Edit:
      break
    case .New:
      break
    }
  }
}
