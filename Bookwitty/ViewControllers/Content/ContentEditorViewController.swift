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
final class SelectedImageView: UIImageView {
  private var selected = false
  
  var isSelected : Bool {
    get {
      return selected
    }
    set {
      selected = newValue
    }
  }
}

class ContentEditorViewController: UIViewController {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  @IBOutlet weak var editorView: RichEditorView!

  @IBOutlet weak var titleTextField: UITextField!

  let viewModel = ContentEditorViewModel()
  
  private var timer: Timer!
  var toolbarButtons: [ContentEditorOption:SelectedImageView] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.editorView.delegate = self
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
    
    let imageSize = CGSize(width: 32.0, height: 32.0)
    
    let plusBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").imageWithSize(size: imageSize),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.plusBarButtonTouchUpInside(_:)))
    
    let nextBarButtonItem = UIBarButtonItem(title: Strings.next(),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.nextBarButtonTouchUpInside(_:)))
    
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
    
    navigationItem.titleView = stackView
    
    let leftBarButtonItems = [closeBarButtonItem, draftsBarButtonItem]
    let rightBarButtonItems = [nextBarButtonItem, plusBarButtonItem]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
  
  // MARK: - Navigation items actions
  @objc private func undoButtonTouchUpInside(_ sender: UIButton) {
    self.editorView.undo()
  }
  
  @objc private func redoButtonTouchUpInside(_ sender: UIButton) {
    self.editorView.redo()
  }
  
  @objc private func closeBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.timer.invalidate()
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func draftsBarButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.presentDraftsViewController()
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
    
    self.viewModel.dispatchContent()
    
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
      if let alertTextField = alertController.textFields?.first, alertTextField.text != nil, let link = alertTextField.text {
        self.editorView.generate(link: URL(string: link), text: "Link")
      }
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
    setupContentEditorHtml()
    self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ContentEditorViewController.tick), userInfo: nil, repeats: true)
    self.timer.tolerance = 0.5
  }
  
  func setupContentEditorHtml() {
    let bundle = Bundle(for: MobileEditor.self)
    bundle.load()
    if let editor = bundle.url(forResource: "editor", withExtension: "html") {
      self.editorView.webView.loadRequest(URLRequest(url: editor))
    }
  }
  
  @objc private func tick() {
    self.viewModel.dispatchContent()
  }
  
  private func setupEditorToolbar() {
    let toolbar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45.0))
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
    onePixelView.backgroundColor = ThemeManager.shared.currentTheme.colorNumber18()
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
      if (isSelected) {
        self.editorView.runJS("HL.removeSelectedElements('h2')")
      } else {
        self.editorView.header(2)
      }
    case .unorderedList:
      self.editorView.unorderedList()
    case .link:
        self.showAddLinkAlertView()
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
  
  func set(option:ContentEditorOption, selected: Bool) {
    guard let item = self.toolbarButtons[option] else { return }
    item.isSelected = selected
    let tint: UIColor = selected ? ThemeManager.shared.currentTheme.colorNumber19() : ThemeManager.shared.currentTheme.colorNumber15()
    item.tintColor = tint
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
      contentViewBottomConstraintToSuperview.constant = frame.height
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

  func presentDraftsViewController() {
    let controller = DraftsViewController()
    controller.delegate = self
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
}

//MARK: - RichEditorToolbarDelegate Implementation
extension ContentEditorViewController: RichEditorToolbarDelegate {
  
  func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    self.showAddLinkAlertView()
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
//MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate Implementation
extension ContentEditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }

    self.navigationController?.dismiss(animated: true, completion: nil)

    viewModel.upload(image: image) { (success: Bool, link: String?) in
      guard let link = link, let Url = URL(string: link) else { return }
      self.editorView.generate(photo: Url, alt: "Image")
    }
  }
}

//MARK: - DraftsViewControllerDelegate Implementation
extension ContentEditorViewController: DraftsViewControllerDelegate {
  func drafts(viewController: DraftsViewController, didRequestEdit draft: CandidatePost) {
    //TODO: Set the candidate post and reload the editor
  }
}

//MARK: - RichBookViewControllerDelegate Implementation
extension ContentEditorViewController: RichBookViewControllerDelegate {
  func richBookViewController(_ richBookViewController: RichBookViewController, didSelect book: Book) {
    self.navigationController?.dismiss(animated: true, completion: nil)
    //TODO: Send to JS
    self.editorView.generate(link: book.canonicalURL, text: book.title)
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
    
    self.editorView.generate(embed: response.html)
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
  func presentSelectPenNameViewController() {
    guard let currentPost = self.viewModel.currentPost, let currentPostId = currentPost.id else {
      return
    }

    let selectPenNameViewController = Storyboard.Account.instantiate(SelectPenNameViewController.self)
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
    self.viewModel.dispatchContent()
  }
}

extension ContentEditorViewController {
  func saveAsDraft() {
    //Ask the content editor for the body.
   self.viewModel.dispatchContent()
  }
}

//MARK: - PublishMenuViewControllerDelegate Implementation
extension ContentEditorViewController: PublishMenuViewControllerDelegate {
  
  func publishMenu(_ viewController: PublishMenuViewController, didSelect item: PublishMenuViewController.Item) {
    viewController.dismiss(animated: true, completion: nil)
    
    switch item {
    case .penName:
      self.presentSelectPenNameViewController()
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

//MARK: - SelectPenNameViewControllerDelegate implementation
extension ContentEditorViewController: SelectPenNameViewControllerDelegate {
  func selectPenName(controller: SelectPenNameViewController, didSelect penName: PenName?) {
    controller.dismiss(animated: true, completion: nil)
    //TODO: Empty Implementation
  }
}

extension ContentEditorViewController: LinkTagsViewControllerDelegate {
  func linkTags(viewController: LinkTagsViewController, didLink tags:[Tag]) {
    self.viewModel.linkedTags = tags
    viewController.dismiss(animated: true, completion: nil)
  }
}

//MARK: - LinkTopicsViewControllerDelegate Implementation
extension ContentEditorViewController: LinkTopicsViewControllerDelegate {
  func linkTopics(viewController: LinkTopicsViewController, didLink topics: [Topic]) {
    self.viewModel.linkedTopics = topics
    viewController.dismiss(animated: true, completion: nil)
  }
}

//MARK: - PostPreviewViewControllerDelegate Implementation
extension ContentEditorViewController: PostPreviewViewControllerDelegate {
  func postPreview(viewController: PostPreviewViewController, didFinishPreviewing post: CandidatePost) {
    viewController.dismiss(animated: true, completion: nil)
    self.viewModel.dispatchContent()
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

//MARK: - RichEditorDelegate implementation
extension ContentEditorViewController: RichEditorDelegate {
  func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
  }
  
  func richEditorDidLoad(_ editor: RichEditorView) {
    editor.runJS("RE.focus();")
  }
  
  func richEditorTookFocus(_ editor: RichEditorView) {
    self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
  }
  
  func richEditorLostFocus(_ editor: RichEditorView) {
    self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
  }
  
  func richEditor(_ editor: RichEditorView, handle action: String) {
    
    if action == "selectionchange" {
      let editingItems = self.editorView.runJS("RE.enabledCommands()").components(separatedBy: ",")
      
      self.set(option: .header, selected: editingItems.contains("h2"))
      self.set(option: .bold, selected: editingItems.contains("bold"))
      self.set(option: .italic, selected: editingItems.contains("italic"))
      self.set(option: .link, selected: editingItems.contains("a"))
      self.set(option: .unorderedList, selected: editingItems.contains("unorderedList"))
    }
  }
}
