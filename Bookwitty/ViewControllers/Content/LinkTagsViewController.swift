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
  func linkTags(viewController: LinkTagsViewController, didLink tags:[Tag])
}

class LinkTagsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tagsView: WSTagsField!
  @IBOutlet weak var tableViewBottomConstraintToSuperview: NSLayoutConstraint!
  @IBOutlet weak var separatorView: UIView!
  weak var delegate: LinkTagsViewControllerDelegate?
  let viewModel = LinkTagsViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
    self.addKeyboardNotifications()
    self.initializeComponents()

    self.title = Strings.tags()
  }
  
  private func initializeComponents() {
    let doneButton = UIBarButtonItem(title: Strings.done(), style: .plain, target: self, action: #selector(doneButtonTouchUpInside(_:)))
    doneButton.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    self.navigationItem.rightBarButtonItem = doneButton
    
    self.separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    tagsView.delimiter = "\n"
    tagsView.beginEditing() // becomeFirstResponder

    tagsView.addTags(self.viewModel.selectedTags.flatMap { $0.title } )
    
    tagsView.onVerifyTag = { [weak self] field, candidate in
      guard let strongSelf = self else {
        return false
      }
      return strongSelf.viewModel.canLink && strongSelf.viewModel.selectedTags.flatMap { $0.title }.contains(candidate)
    }
    
    tagsView.onDidChangeText = { [weak self] field, text in
      guard let strongSelf = self else {
        return
      }
      NSObject.cancelPreviousPerformRequests(withTarget: strongSelf)
      strongSelf.perform(#selector(LinkTagsViewController.reload), with: text, afterDelay: 0.5)
    }
    tagsView.onShouldReturn = { _ in
      return false
    }
    tagsView.onDidRemoveTag = { [weak self] _, tag in
      guard let strongSelf = self else {
        return
      }
      strongSelf.viewModel.selectedTags = strongSelf.viewModel.selectedTags.filter { !($0.title == tag.text) }
      _ = TagAPI.removeTag(for: strongSelf.viewModel.contentIdentifier, with: tag.text, completion: { (success, error) in
        guard success else {
          return
        }
      })
    }
    
    tagsView.onDidAddTag = { [weak self] _, tag in
      guard let strongSelf = self else {
        return
      }
      
      _ = TagAPI.linkTag(for: strongSelf.viewModel.contentIdentifier, with: tag.text, completion: { (success, error) in
        guard success else {
          return
        }
      })
    }
    
    tableView.tableFooterView = UIView() //Hacky
    tableView.backgroundColor = .clear
  }

  @objc private func reload(with text: String?) {
    guard let text = text, text.characters.count > 0 else {
      return
    }
    
    self.viewModel.filter.query = text
    //Perform request
    _ = SearchAPI.autocomplete(filter: self.viewModel.filter, page: nil) { (success, tags, _, _, error) in
      guard success, let tags = tags as? [Tag] else {
        self.viewModel.tags = []
        return
      }
      self.viewModel.tags = tags
      self.tableView.reloadData()
    }
  }

  @objc private func doneButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.delegate?.linkTags(viewController: self, didLink: self.viewModel.selectedTags)
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

extension LinkTagsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfItemsInSection(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "tagCellIdentifier", for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.textLabel?.text = self.viewModel.values(forRowAt: indexPath)
    cell.textLabel?.font = FontDynamicType.caption1.font
    cell.detailTextLabel?.text = ""
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.viewModel.append(self.viewModel.tags[indexPath.row])
    self.tagsView.addTags(self.viewModel.selectedTags.flatMap { $0.title })
    self.viewModel.tags = []
    tableView.reloadData()
  }
}
