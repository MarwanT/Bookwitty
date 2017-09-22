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
                                action: nil)
    
    let drafts = UIBarButtonItem(title: Strings.drafts(),
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: nil)
    
    let undo = UIBarButtonItem(image: #imageLiteral(resourceName: "undo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    
    let redo = UIBarButtonItem(image: #imageLiteral(resourceName: "redo"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    let plus = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"),
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    
    let next = UIBarButtonItem(title: Strings.next(),
                                style: UIBarButtonItemStyle.plain,
                                target: self,
                                action: nil)
   
    let leftBarButtonItems = [close,drafts,undo]
    let rightBarButtonItems = [next,plus,redo]
    
    navigationItem.leftBarButtonItems = leftBarButtonItems
    navigationItem.rightBarButtonItems = rightBarButtonItems
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
    toolbar.tintColor = ThemeManager.shared.currentTheme.defaultTextColor()
    toolbar.options = ContentEditorOption.toolbarOptions
    toolbar.editor = editor // Previously instantiated RichEditorView
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
}
