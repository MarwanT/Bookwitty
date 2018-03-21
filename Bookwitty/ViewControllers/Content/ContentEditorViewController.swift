//
//  ContentEditorViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import RichEditorView
import MobileEditor
import SwiftLoader

class ContentEditorViewController: UIViewController {

  @IBOutlet weak var editorViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  @IBOutlet weak var editorView: RichEditorView!
  fileprivate var isEditorLoaded: Bool = false

  @IBOutlet weak var titleTextField: UITextField!
  /**
   The **titleTextFieldInspectorView** is a layer of top of the **titleTextField**
   This solution was implemented because we needed a way to trigger a **backupRange**
   for the **editorView** before it looses focus, and the focus is taken by the
   **titleTextField** itself.
   */
  @IBOutlet weak var titleTextFieldInspectorView: UIView!
  @IBOutlet weak var topTitleSeparator: UIView!
  @IBOutlet weak var bottomTitleSeparator: UIView!
  
  let viewModel = ContentEditorViewModel()
  
  fileprivate var shouldBackupRange: Bool = false
  
  private var timer: Timer!
  var toolbarButtons: [ContentEditorOption:SelectedImageView] = [:]
  func hasContent(completion: @escaping (Bool) -> Void) {
    self.editorView.isEmpty { (empty) in
      let title = self.titleTextField.text ?? ""
      completion(title.count > 0 || !empty)
    }
  }
  enum DispatchStatus {
    case create
    case update
    case noChanges
  }
  
  enum Mode {
    case new
    case edit
    
    var isEditing: Bool {
      return self == .edit
    }
  }
  
  var mode: Mode = .new
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
   
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
    setupTitleTextField()
    initializeRichEditorEcosystem()
    loadNavigationBarButtons()
    addKeyboardNotifications()
    observeLanguageChanges()
    applyLocalization()
  }
  
  @objc private func textChanged(_ sender: UITextField) {
    guard let text = sender.text else {
      self.viewModel.currentPost?.title = nil
      return
    }
    self.viewModel.currentPost?.title = text
  }
  
  fileprivate func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    
    let closeBarButtonItem = UIBarButtonItem(title: Strings.close(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.closeBarButtonTouchUpInside(_:)))
    
    let draftsBarButtonItem = UIBarButtonItem(title: Strings.drafts(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(self.draftsBarButtonTouchUpInside(_:)))
    
    let imageSize = CGSize(width: 32.0, height: 32.0)
    
    let plusBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").imageWithSize(size: imageSize),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.plusBarButtonTouchUpInside(_:)))
    
    self.editorView.hasFocus { (has) in
      plusBarButtonItem.isEnabled = has
    }

    let nextBarButtonItem = UIBarButtonItem(title: Strings.next(),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.nextBarButtonTouchUpInside(_:)))

    nextBarButtonItem.isEnabled = self.viewModel.publishable
    nextBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: ThemeManager.shared.currentTheme.defaultGrayedTextColor()], for: .disabled)
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
    
    let titleView = UIView(frame: .init(x: 0, y: 0, width: 44.0 + 5.0 + 44.0, height: 44.0))
    titleView.addSubview(stackView)
    stackView.bindFrameToSuperviewBounds()
    navigationItem.titleView = titleView
    
    let leftBarButtonItems = [closeBarButtonItem, draftsBarButtonItem]
    let rightBarButtonItems = [nextBarButtonItem, plusBarButtonItem]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }

  func resignResponders() {
    _ = self.titleTextField.resignFirstResponder()
    _ = self.editorView.endEditing(true)
  }
  
  fileprivate func dispatchContent(_ completion:((_ created: ContentEditorViewController.DispatchStatus, _ success: Bool) -> Void)? = nil) {
    self.hasContent { (has) in
      self.viewModel.dispatchContent(hasContent: has, completion)
    }
  }
  
  func dismiss() {
    self.stopTimer()
    self.dismiss(animated: true, completion: nil)
  }
  
  func backupRangeIfNeeded() {
    guard shouldBackupRange else {
      return
    }
    
    shouldBackupRange = false
    editorView.backupRange()
  }
  
  func didTapOnTextFieldInterceptor(_ sender: Any?) {
    backupRangeIfNeeded()
    titleTextField.becomeFirstResponder()
  }
  
  // MARK: - Navigation items actions
  @objc private func undoButtonTouchUpInside(_ sender: UIButton) {
    self.editorView.undo()
  }
  
  @objc private func redoButtonTouchUpInside(_ sender: UIButton) {
    self.editorView.redo()
  }
  
  @objc private func closeBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.resignResponders()
    
    presentConfirmSaveOrDiscardActionSheet { (option: ContentEditorViewController.ConfirmationOption, success: Bool) in
      switch option {
      case .saveDraft where success: fallthrough
      case .discardChanges where success: fallthrough
      case .nonNeeded:
        self.dismiss()
      default:
        break
      }
    }
  }
  
  @objc private func draftsBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.present(.drafts)
  }
  
  @objc private func plusBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.present(.richContentMenu)
  }
  
  @objc private func nextBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.present(.publishMenu)
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
  
  func showAddLinkAlertView(with link:String?) {
    let alertController = UIAlertController(title: Strings.addLink(), message: "", preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: Strings.ok(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
      if let alertTextField = alertController.textFields?.first, alertTextField.text != nil, let link = alertTextField.text {
        self.editorView.insertLink(link, title: "")
      }
    })
    
    alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
      textField.placeholder = "http://"
      
      textField.text = link
    })
    
    alertController.addAction(confirmAction)
    
    let cancelAction = UIAlertAction(title: Strings.cancel(), style: .cancel, handler: nil)
    alertController.addAction(cancelAction)

    backupRangeIfNeeded()
    resignResponders()
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Timer
  func startTimer() {
    self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ContentEditorViewController.tick), userInfo: nil, repeats: true)
    self.timer.tolerance = 0.5
  }
  
  func stopTimer() {
    self.timer.invalidate()
  }

  // MARK: - RichEditor
  private func initializeRichEditorEcosystem() {
    setupEditorToolbar()
    setupContentEditorHtml()
    startTimer()
    self.editorView.clipsToBounds = true
  }
  
  func setupContentEditorHtml() {
    let bundle = Bundle(for: MobileEditor.self)
    bundle.load()
    if let editor = bundle.url(forResource: "editor", withExtension: "html") {
        self.editorView.webView.load(URLRequest(url: editor))
    }
    self.editorView.delegate = self
  }
  
  @objc private func tick() {
    self.dispatchContent() { [unowned self] status, success in
        if success {
          self.loadNavigationBarButtons()
      }
    }
  }
  
  private func setupTitleTextField() {
    self.titleTextField.addTarget(self, action: #selector(ContentEditorViewController.textChanged(_:)), for: .editingChanged)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnTextFieldInterceptor(_:)))
    self.titleTextFieldInspectorView.addGestureRecognizer(tapGesture)
  }
  
  private func setupEditorToolbar() {
    let toolbar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 43.0))
    toolbar.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    editorView.inputAccessoryView = toolbar

    
    let options = ContentEditorOption.toolbarOptions
    let items = createToolbarItems(with: options)
    
    let stackView = UIStackView(arrangedSubviews: items)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    let verticalStackView = UIStackView()
    verticalStackView.axis = .vertical
    let onePixelView = UIView()
    onePixelView.translatesAutoresizingMaskIntoConstraints = false
    onePixelView.addHeightConstraint(1)
    onePixelView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    verticalStackView.distribution = .fillProportionally
    verticalStackView.addArrangedSubview(onePixelView)
    verticalStackView.addArrangedSubview(stackView)
    toolbar.addSubview(verticalStackView)
    verticalStackView.bindFrameToSuperviewBounds()
  }
  
  func toolbarItemTouchUpInside(_ sender: UITapGestureRecognizer) {
    guard let option = ContentEditorOption(rawValue: sender.view!.tag) else { return }
    let isSelected = self.toolbarButtons[option]?.isSelected ?? false

    switch option {

    case .bold:
      self.editorView.bold()
    case .italic:
        self.editorView.italic()
    case .header:
        self.editorView.setHeader()
    case .unorderedList:
      self.editorView.unorderedList()
    case .link:
      if isSelected {
        self.editorView.selectedHref(completion: { (_ previousLink: String) in
          self.showAddLinkAlertView(with: previousLink)
        })
      } else {
        self.showAddLinkAlertView(with: nil)
      }
    case .undo, .redo :
      break
    }
    
    self.richEditor(self.editorView, handle: "selectionchange")
  }
  
  func createToolbarItems(with options:[ContentEditorOption]) -> [SelectedImageView] {
    var items = [SelectedImageView]()
    options.forEach {
      let toolbarImageView = SelectedImageView(image: $0.image)
      toolbarImageView.isUserInteractionEnabled = true
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toolbarItemTouchUpInside(_:)))
      toolbarImageView.addGestureRecognizer(tapGestureRecognizer)
      toolbarImageView.tag = $0.rawValue
      toolbarImageView.translatesAutoresizingMaskIntoConstraints = false
      toolbarImageView.addSizeConstraints(width: 44.0, height: 44.0)
      toolbarImageView.tintColor = ThemeManager.shared.currentTheme.colorNumber15()
      items.append(toolbarImageView)
      self.toolbarButtons[$0] = toolbarImageView
    }
    items.append(SelectedImageView())
    return items
  }
  
  func set(option:ContentEditorOption, selected: Bool, isEnabled: Bool = true) {
    guard let item = self.toolbarButtons[option] else { return }
    item.isSelected = selected
    let tint: UIColor = isEnabled ? (selected ? ThemeManager.shared.currentTheme.colorNumber19() : ThemeManager.shared.currentTheme.colorNumber20()) : ThemeManager.shared.currentTheme.defaultGrayedTextColor()
    item.tintColor = tint
    item.isUserInteractionEnabled = isEnabled
  }
  
  // MARK: - UI Refresh
  fileprivate func loadUIFromPost() {
    self.titleTextField.text  = self.viewModel.currentPost.title
    self.editorView.setContent(html: self.viewModel.currentPost.body)
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
      editorViewBottomConstraintToSuperview.constant = frame.height
    }
    
    if editorView.containsFirstResponder {
      shouldBackupRange = true
    }
    
    UIView.animate(withDuration: 0.44) {
      self.editorView.setNeedsUpdateConstraints()
      self.view.layoutSubviews()
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    editorViewBottomConstraintToSuperview.constant = 0
    UIView.animate(withDuration: 0.44) {
      self.editorView.setNeedsUpdateConstraints()
      self.view.layoutSubviews()
    }
  }
}

// MARK: - The Presenters
extension ContentEditorViewController {
  enum Destination {
    case richContentMenu
    case publishMenu
    case imagePicker(UIImagePickerControllerSourceType)
    case richBook
    case drafts
    case richLink(RichLinkPreviewViewController.Mode)
    case quoteEditor
    case selectPenName
    case tags
    case linkTopics
    case postPreview
  }
  
  fileprivate func present(_ destination: Destination) {
    /**
     Backing up the editor range is necessary for avoiding the
     Weird behavior when resuming editing
     */
    
    backupRangeIfNeeded()
    
    /**
     Resign the editor as responder for in most cases, upon showing another
     vc on top of this one, when we come back to this vc on top
     the keyboard is dismissed but the toolbar is still visible
     */
    
    resignResponders()
    
    switch destination {
    case .richContentMenu:
      presentRichContentMenuViewController()
    case .publishMenu:
      presentPublishMenuViewController()
    case .imagePicker(let imagePickerControllerSourceType):
      presentImagePicker(with: imagePickerControllerSourceType)
    case .richBook:
      presentRichBookViewController()
    case .drafts:
      presentDraftsViewController()
    case .richLink(let richLinkPreviewMode):
      presentRichLinkViewController(with: richLinkPreviewMode)
    case .quoteEditor:
      presentQuoteEditorViewController()
    case .selectPenName:
      presentSelectPenNameViewController()
    case .tags:
      presentTagsViewController()
    case .linkTopics:
      presentLinkTopicsViewController()
    case .postPreview:
      presentPostPreviewViewController()
    }
  }
  
  // MARK: Navigation Toolbar Actions Handling
  fileprivate func  presentRichContentMenuViewController() {
    let richContentMenuViewController = Storyboard.Content.instantiate(RichContentMenuViewController.self)
    richContentMenuViewController.delegate = self
    self.definesPresentationContext = true
    richContentMenuViewController.view.backgroundColor = .clear
    richContentMenuViewController.modalPresentationStyle = .overCurrentContext
    
    self.navigationController?.present(richContentMenuViewController, animated: true, completion: nil)
  }
  
  fileprivate func presentPublishMenuViewController() {
    self.dispatchContent()
    
    let publishMenuViewController = Storyboard.Content.instantiate(PublishMenuViewController.self)
    publishMenuViewController.delegate = self
    publishMenuViewController.viewModel.initialize(with: self.viewModel.currentPost.id, linkedTags: self.viewModel.linkedTags, linkedPages: self.viewModel.linkedPages, isEditing: self.mode.isEditing)
    self.definesPresentationContext = true
    publishMenuViewController.view.backgroundColor = .clear
    publishMenuViewController.modalPresentationStyle = .overCurrentContext
    
    self.navigationController?.present(publishMenuViewController, animated: true, completion: nil)
  }
  
  // MARK: User Import Action(s) Handling
  func presentImagePicker(with source: UIImagePickerControllerSourceType) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = source
    imagePickerController.allowsEditing = false
    self.navigationController?.present(imagePickerController, animated: true, completion: nil)
  }
  
  func presentRichBookViewController() {
    let richBookViewController = RichBookViewController()
    richBookViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: richBookViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
  func presentDraftsViewController() {
    let controller = DraftsViewController()
    controller.delegate = self
    controller.exclude(self.viewModel.currentPost.id)
    let navigationController = UINavigationController(rootViewController: controller)
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
  
  // MARK: Publishing Actions Handling
  func presentSelectPenNameViewController() {
    guard let currentPost = self.viewModel.currentPost, let currentPostId = currentPost.id else {
      return
    }
    
    let selectPenNameViewController = Storyboard.Account.instantiate(SelectPenNameViewController.self)
    selectPenNameViewController.viewModel.preselect(penName: currentPost.penName)
    selectPenNameViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: selectPenNameViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
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
    
    let linkTopicsViewController = Storyboard.Content.instantiate(LinkPagesViewController.self)
    linkTopicsViewController.viewModel.initialize(with: currentPostId, linkedPages: self.viewModel.linkedPages)
    linkTopicsViewController.delegate = self
    let navigationController = UINavigationController(rootViewController: linkTopicsViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
  func presentPostPreviewViewController() {
    guard let currentPost = self.viewModel.currentPost else {
      return
    }
    
    var title: String = ""
    var description: String? = currentPost.shortDescription
    var fallbackDescription: String?
    var imageURL: String? = currentPost.imageUrl

    self.editorView.getDefaults { (_ defaultTitle: String, _ defaultDescription: String?, _ defaultImageURL: String?) in
      title = currentPost.title ?? defaultTitle
      description = description ?? defaultDescription
      fallbackDescription = defaultDescription
      imageURL = imageURL ?? defaultImageURL

      let postPreviewViewController = PostPreviewViewController()
      postPreviewViewController.initialize(with: self.viewModel.currentPost, and: (title, description, fallbackDescription, imageURL))
      postPreviewViewController.delegate = self
      let navigationController = UINavigationController(rootViewController: postPreviewViewController)
      self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
  }
}

//MARK: - Localizable implementation
extension ContentEditorViewController: Localizable {
  func applyLocalization() {
    // Title Placeholder
    titleTextField.attributedPlaceholder = NSAttributedString(
      string: "\(Strings.title()) (\(Strings.optional()))",
      attributes: [NSForegroundColorAttributeName : ThemeManager.shared.currentTheme.defaultGrayedTextColor()])
    // Editor placeholder
    editorView.set(placeholder: Strings.write_here(), completion: nil)
    // Navigation buttons
    loadNavigationBarButtons()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

//MARK: - Save Action Sheet
extension ContentEditorViewController {
  enum ConfirmationOption {
    case saveDraft
    case discardChanges
    case goBack
    case nonNeeded
  }

  fileprivate func presentConfirmSaveOrDiscardActionSheet(_ closure : @escaping (_ option: ConfirmationOption, _ success: Bool) -> ()) {
    var hasContent = false
    
    let group = DispatchGroup()
    group.enter()
    self.hasContent { (has) in
      hasContent = has
      group.leave()
    }
    
    group.notify(queue: DispatchQueue.main) {
      guard hasContent else {
        closure(.nonNeeded, true)
        return
      }
      
      // The flag `needsRemoteSync` also checks if `needsLocalSync`
      guard self.viewModel.needsRemoteSync else {
        closure(.nonNeeded, true)
        return
      }
      
      // Stop Timer for the alert controller will be displayed
      self.stopTimer()
      
      // Prepare and Display the Confirmation Alert Controller
      let alertTitle = self.mode.isEditing ? Strings.discard_changes_confirmation_question() : Strings.save_draft_changes()
      let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
      
      if self.mode.isEditing {
        // Editing a published post
      } else {
        // Editing a draft
        let saveDraft = UIAlertAction(
          title: Strings.save_draft(), style: .default, handler: { _ in
            self.savePostAsDraft({ (success: Bool) in
              closure(.saveDraft, success)
            })
        })
        alertController.addAction(saveDraft)
      }
      
      let discardPost = UIAlertAction(
        title: Strings.discard_changes(), style: .destructive, handler: { _ in
          closure(.discardChanges, true)
      })
      
      let goBack = UIAlertAction(title: Strings.go_back(), style: .cancel, handler: {
        _ in
        self.startTimer()
        closure(.goBack, true)
      })
      
      alertController.addAction(discardPost)
      alertController.addAction(goBack)
      
      self.navigationController?.present(alertController, animated: true, completion: nil)
    }
  }

  fileprivate func showRetryAlert(with title: String?, message: String?, closure: ((_ retry: Bool) -> ())?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let tryAgainAction = UIAlertAction(title: Strings.try_again(), style: .default, handler: {
      _ in
      closure?(true)
    })

    let cancelAction = UIAlertAction(title: Strings.cancel(), style: .cancel, handler: {
      _ in
      closure?(false)
    })

    alertController.addAction(tryAgainAction)
    alertController.addAction(cancelAction)
    navigationController?.present(alertController, animated: true, completion: nil)
  }

  fileprivate func discardPost(_ closure: @escaping (Bool) -> ()) {
    SwiftLoader.show(animated: true)
    self.viewModel.deletePost {
      (success: Bool, error: BookwittyAPIError?) in
      SwiftLoader.hide()
      if success {
        closure(success)
      } else {
        self.showRetryAlert(with: Strings.error(), message: Strings.some_thing_wrong_error(), closure: {
          (retry: Bool) in
          if retry {
            self.discardPost(closure)
          } else {
            closure(false)
          }
        })
      }
    }
  }

  fileprivate func savePostAsDraft(_ closure: @escaping (Bool) -> ()) {
    SwiftLoader.show(animated: true)
    self.editorView.getDefaults { (_ defaultTitle: String, _ defaultDescription: String?, _ defaultImageURL: String?) in
      let defaultValues = (defaultTitle, defaultDescription, defaultImageURL)
      self.viewModel.saveAndSynchronize(with: defaultValues) {
        (success: Bool) in
        SwiftLoader.hide()
        if success {
          closure(success)
        } else {
          self.showRetryAlert(with: Strings.error(), message: Strings.some_thing_wrong_error(), closure: {
            (retry: Bool) in
            if retry {
              self.savePostAsDraft(closure)
            } else {
              closure(false)
            }
          })
        }
      }
    }
  }
}

//MARK: - RichEditorToolbarDelegate Implementation
extension ContentEditorViewController: RichEditorToolbarDelegate {
  
  func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    self.showAddLinkAlertView(with: nil)
  }
}

//MARK: - RichContentMenuViewControllerDelegate Implementation
extension ContentEditorViewController : RichContentMenuViewControllerDelegate {
  
  func richContentMenuViewControllerDidCancel(_ richContentMenuViewController: RichContentMenuViewController) {
    richContentMenuViewController.dismiss(animated: true, completion: nil)
  }
  
  func richContentMenuViewController(_ richContentMenuViewController: RichContentMenuViewController, didSelect item: RichContentMenuViewController.Item) {
    richContentMenuViewController.dismiss(animated: true, completion: nil)
    switch item {
    case .imageCamera:
      self.present(.imagePicker(.camera))
    case .imageLibrary:
      self.present(.imagePicker(.photoLibrary))
    case .link:
      self.present(.richLink(.link))
    case .book:
      self.present(.richBook)
    case .video:
      self.present(.richLink(.video))
    case .audio:
      self.present(.richLink(.audio))
    case .quote:
      self.present(.quoteEditor)
    }
  }
}
//MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate Implementation
extension ContentEditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }

    let imageCropper = CropViewController(with: image)
    imageCropper.delegate = self
    picker.present(imageCropper, animated:true)
  }
}

//MARK: - DraftsViewControllerDelegate Implementation
extension ContentEditorViewController: DraftsViewControllerDelegate {
  func drafts(viewController: DraftsViewController, didRequestEdit draft: CandidatePost) {
    self.navigationController?.dismiss(animated: true, completion: { 
      self.presentConfirmSaveOrDiscardActionSheet { (option: ContentEditorViewController.ConfirmationOption, success: Bool) in
        switch option {
        case .saveDraft where success: fallthrough
        case .discardChanges where success: fallthrough
        case .nonNeeded:
          self.viewModel.set(draft)
          self.loadUIFromPost()
        default:
          break
        }
      }
    })
  }

  func draftsViewControllerRequestClose(_ viewController: DraftsViewController) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

//MARK: - RichBookViewControllerDelegate Implementation
extension ContentEditorViewController: RichBookViewControllerDelegate {
  func richBookViewController(_ richBookViewController: RichBookViewController, didSelect book: Book, with response: Response?) {
    self.navigationController?.dismiss(animated: true, completion: nil)
    guard let response = response else {
      return
    }
    self.editorView.generateLinkPreview(type: "book", title: response.title, description: response.shortDescription, url: response.url, imageUrl: response.thumbnails?.first?.url, html: response.html)
  }
}

extension ContentEditorViewController: RichLinkPreviewViewControllerDelegate {
  func richLinkPreview(viewController: RichLinkPreviewViewController, didRequestLinkAdd: URL, with response: Response) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
    var mode: String = ""
    switch viewController.mode {
    case .link:
      mode = "link"
    case .audio:
      mode = "audio"
    case .video:
      mode = "video"
    }
    
    self.editorView.generateLinkPreview(type: mode, title: response.title, description: response.shortDescription, url: response.url, imageUrl: response.thumbnails?.first?.url, html: response.html)
  }

  func richLinkPreviewViewControllerDidCancel(_ viewController: RichLinkPreviewViewController) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController: QuoteEditorViewControllerDelegate {
  func quoteEditor(viewController: QuoteEditorViewController, didRequestAdd quote: String, with author: String?) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
    self.editorView.generate(quote: quote, author: author ?? "", citeText: "", citeUrl: "")
  }

  func quoteEditorViewControllerDidCancel(_ viewController: QuoteEditorViewController) {
    viewController.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ContentEditorViewController {
  func publishYourPost(_ completion: ((_ success: Bool) -> Void)? = nil) {
    self.viewModel.preparePostForPublish()
    self.editorView.getDefaults { (_ defaultTitle: String, _ defaultDescription: String?, _ defaultImageURL: String?) in
      let defaultValues = (defaultTitle, defaultDescription, defaultImageURL)
      self.viewModel.updateContent(with: defaultValues) { success in
        completion?(success)
      }
    }
  }
}

extension ContentEditorViewController {
  func saveAsDraft(_ completion:((_ success:Bool) -> Void)?) {
    //Ask the content editor for the body.
    self.dispatchContent { _, success in
      completion?(success)
    }
  }
}

//MARK: - PublishMenuViewControllerDelegate Implementation
extension ContentEditorViewController: PublishMenuViewControllerDelegate {
  
  func publishMenu(_ viewController: PublishMenuViewController, didSelect item: PublishMenuViewController.Item) {
    
    switch item {
    case .penName:
      viewController.dismiss(animated: true, completion: nil)
      self.present(.selectPenName)
    case .linkTopics:
      viewController.dismiss(animated: true, completion: nil)
      self.present(.linkTopics)
    case .addTags:
      viewController.dismiss(animated: true, completion: nil)
      self.present(.tags)
    case .postPreview:
      viewController.dismiss(animated: true, completion: nil)
      self.present(.postPreview)
    case .publishYourPost:
      SwiftLoader.show(animated: true)
      self.publishYourPost() { success in
        SwiftLoader.hide()
        if success {
          viewController.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: AppNotification.shouldRefreshData, object: nil)
            self.dismiss(animated: true, completion: nil)
          })
        } else {
          //TODO: Show the user an error alert
        }
      }
    case .saveAsDraft:
      SwiftLoader.show(animated: true)
      self.savePostAsDraft({ (success: Bool) in
        SwiftLoader.hide()
        if success {
          self.resignResponders()
          viewController.dismiss(animated: false, completion: {
            self.dismiss(animated: true, completion: nil)
          })
        }
      })
    case .goBack:
      viewController.dismiss(animated: true, completion: nil)
    }
  }
}

//MARK: - SelectPenNameViewControllerDelegate implementation
extension ContentEditorViewController: SelectPenNameViewControllerDelegate {
  func selectPenName(controller: SelectPenNameViewController, didSelect penName: PenName?) {
    controller.dismiss(animated: true) {
      self.present(.publishMenu)
    }
    //TODO: Empty Implementation
  }
}

extension ContentEditorViewController: LinkTagsViewControllerDelegate {
  func linkTags(viewController: LinkTagsViewController, didLink tags:[Tag]) {
    self.viewModel.linkedTags = tags
    viewController.dismiss(animated: true) {
      self.present(.publishMenu)
    }
  }
}

//MARK: - LinkPagesViewControllerDelegate Implementation
extension ContentEditorViewController: LinkPagesViewControllerDelegate {
  func linkPages(viewController: LinkPagesViewController, didLink pages: [ModelCommonProperties]) {
    self.viewModel.linkedPages = pages
    viewController.dismiss(animated: true) {
      self.present(.publishMenu)
    }
  }
}

//MARK: - PostPreviewViewControllerDelegate Implementation
extension ContentEditorViewController: PostPreviewViewControllerDelegate {
  func postPreview(viewController: PostPreviewViewController, didFinishPreviewing post: CandidatePost) {
    viewController.dismiss(animated: true) {
      self.present(.publishMenu)
    }
    self.loadUIFromPost()
    self.dispatchContent()
  }
}

//MARK: - PenNameViewControllerDelegate Implementatio
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


//MARK: - CropViewControllerDelegate Implementatio
extension ContentEditorViewController: CropViewControllerDelegate {
  func crop(_ viewController: CropViewController, didFinishWith croppedImage: UIImage) {
    
    let image = croppedImage
    self.navigationController?.dismiss(animated: true, completion: nil)
    
    self.editorView.generatePhotoWrapper() { id in
      self.viewModel.addUploadRequest(id)
      self.loadNavigationBarButtons()
      self.viewModel.upload(image: image) { (success: Bool, link: String?) in
        guard let link = link, let Url = URL(string: link) else { return }
        self.editorView.generate(photo: Url, alt: "Image", wrapperId: id)
        self.viewModel.removeUploadRequest(id)
        self.loadNavigationBarButtons()
      }
    }
  }
}

//MARK: - RichEditorDelegate implementation
extension ContentEditorViewController: RichEditorDelegate {
  func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
    //Always disable url interaction
    return false
  }

  func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
    guard self.isEditorLoaded else { return }
    editor.getContent { (body) in
      self.viewModel.currentPost.body = body
    }
  }
  
  func richEditorDidLoad(_ editor: RichEditorView) {
    self.isEditorLoaded = true
    editor.focus()
    self.loadUIFromPost()
  }
  
  func richEditorTookFocus(_ editor: RichEditorView) {
    self.loadNavigationBarButtons()
  }
  
  func richEditorLostFocus(_ editor: RichEditorView) {
    self.loadNavigationBarButtons()
  }
  
  func richEditor(_ editor: RichEditorView, handle action: String) {
    
    if action == "selectionchange" {
      self.editorView.enabledCommands(completion: { (editingItems) in
        self.set(option: .header, selected: editingItems.contains("h2"))
        self.set(option: .bold, selected: editingItems.contains("bold"))
        self.set(option: .italic, selected: editingItems.contains("italic"))
        let isLink = editingItems.contains("link")
        let isRange = editingItems.contains("isRange");
        self.set(option: .link, selected: isLink, isEnabled: (isLink || isRange))
        self.set(option: .unorderedList, selected: editingItems.contains("unorderedList"))
      })
    } else if action.hasPrefix("removewrapper:") {
      guard let range = action.range(of: "removewrapper:") else {
        return
      }
      let wrapperId = action.substring(from: range.upperBound)
      self.viewModel.removeUploadRequest(wrapperId)
      self.loadNavigationBarButtons()
    }
  }
}

//MARK: - Themeable
extension ContentEditorViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    titleTextField.font = FontDynamicType.title4.font
    titleTextField.textColor = theme.defaultTextColor()
    topTitleSeparator.backgroundColor = theme.defaultSeparatorColor()
    bottomTitleSeparator.backgroundColor = theme.defaultSeparatorColor()
  }
}
