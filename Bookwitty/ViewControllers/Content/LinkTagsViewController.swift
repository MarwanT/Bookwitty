//
//  LinkTagsViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField

protocol LinkTagsViewControllerDelegate: class {
  func linkTags(viewController: LinkTagsViewController, didLink tags:[String])
}

class LinkTagsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tagsView: WSTagsField!
  @IBOutlet weak var tableViewBottomConstraintToSuperview: NSLayoutConstraint!
  weak var delegate: LinkTagsViewControllerDelegate?
  let viewModel = LinkTagsViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
    self.addKeyboardNotifications()
    self.initializeComponents()
  }
  
  private func initializeComponents() {
    let doneButton = UIBarButtonItem(title: Strings.done(), style: .plain, target: self, action: #selector(doneButtonTouchUpInside(_:)))
    doneButton.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    self.navigationItem.rightBarButtonItem = doneButton
    
    tagsView.onVerifyTag = { field, candidate in
      return field.tags.count <= self.viewModel.limit
    }
    
    tagsView.onDidChangeText = { field, text in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(#selector(LinkTagsViewController.reload), with: text, afterDelay: 0.5)
    }
  }

  @objc private func reload(with text: String?) {
    //Todo: Implementation.
  }

  @objc private func doneButtonTouchUpInside(_ sender:UIBarButtonItem) {

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
      self.tableViewBottomConstraintToSuperview.constant = -frame.height
    }
    
    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    self.tableViewBottomConstraintToSuperview.constant = 0
    UIView.animate(withDuration: 0.44) {
      self.view.layoutSubviews()
    }
  }
}

extension LinkTagsViewController: Themeable {
  
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension LinkTagsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "tagCellIdentifier", for: indexPath)
  }
}
