//
//  ContentEditorViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 9/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import RichEditorView

class ContentEditorViewController: UIViewController {
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentViewBottomConstraintToSuperview: NSLayoutConstraint!
  
  private let editor = RichEditorView()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    loadNavigationBarButtons()
    addKeyboardNotifications()
  }
  
  private func loadNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back
    
    let close = UIBarButtonItem(title: Strings.close(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.close(_:)))
    
    let drafts = UIBarButtonItem(title: Strings.drafts(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(self.drafts(_:)))
    
    let undo = UIBarButtonItem(image: #imageLiteral(resourceName: "undo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.undo(_:)))
    
    let redo = UIBarButtonItem(image: #imageLiteral(resourceName: "redo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.redo(_:)))
    let plus = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: #selector(self.plus(_:)))
    
    let next = UIBarButtonItem(title: Strings.next(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: #selector(self.next(_:)))
   
    let leftBarButtonItems = [close,drafts,undo]
    let rightBarButtonItems = [next,plus,redo]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
  
  // MARK: - Navigation items actions
  @objc private func close(_ sender:UIBarButtonItem) {
    //Todo: Implementation
  }
  
  @objc private func drafts(_ sender:UIBarButtonItem) {
    //Todo: Implementation
  }
  
  @objc private func undo(_ sender:UIBarButtonItem) {
    guard let toolbar = editor.inputAccessoryView as? RichEditorToolbar else {
      return
    }
    
    ContentEditorOption.undo.action(toolbar)
  }
  
  @objc private func redo(_ sender:UIBarButtonItem) {
    guard let toolbar = editor.inputAccessoryView as? RichEditorToolbar else {
      return
    }
    
    ContentEditorOption.redo.action(toolbar)
  }
  
  @objc private func plus(_ sender:UIBarButtonItem) {
    let richContentMenuViewController = Storyboard.Content.instantiate(RichContentMenuViewController.self)
    richContentMenuViewController.delegate = self
    self.definesPresentationContext = true
    richContentMenuViewController.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber20().withAlphaComponent(0.5)
    richContentMenuViewController.modalPresentationStyle = .overCurrentContext
    
    self.navigationController?.present(richContentMenuViewController, animated: true, completion: nil)
  }
  
  @objc private func next(_ sender:UIBarButtonItem) {
    //Todo: Implementation
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
      
      guard let toolbar = self.editor.inputAccessoryView as? RichEditorToolbar else {
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
  private func addRichEditorView() {
    self.contentView.addSubview(editor)
    editor.bindFrameToSuperviewBounds()
    //TODO: Localize
    editor.placeholder = "Write Here"
    setupToolbar(of: editor)
  }
  
  private func setupToolbar(of editor:RichEditorView) {
    let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
    toolbar.tintColor = ThemeManager.shared.currentTheme.colorNumber20()
    toolbar.options = ContentEditorOption.toolbarOptions
    toolbar.editor = editor // Previously instantiated RichEditorView
    toolbar.delegate = self
    editor.inputAccessoryView = toolbar
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
    let item = item
    //TODO: Implementation
    print(item)
  }
}

extension ContentEditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }
    //TODO: Send Image to Bucket.
    self.dismiss(animated: true, completion: nil)
  }
}
