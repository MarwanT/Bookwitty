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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
    self.addKeyboardNotifications()
    self.initializeComponents()
    self.applyLocalization()
    self.observeLanguageChanges()
  }
  
  private func initializeComponents() {
    let theme = ThemeManager.shared.currentTheme
    
    let doneButton = UIBarButtonItem(title: Strings.done(), style: .plain, target: self, action: #selector(doneButtonTouchUpInside(_:)))
    doneButton.setTitleTextAttributes(
      [ NSFontAttributeName: FontDynamicType.footnote.font,
        NSForegroundColorAttributeName : theme.colorNumber19()],
      for: UIControlState.normal)
    self.navigationItem.rightBarButtonItem = doneButton
    
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = .clear
    self.tableView.separatorInset = UIEdgeInsets.zero
    self.tableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    self.separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    tagsView.delimiter = "\n"
    tagsView.beginEditing() // becomeFirstResponder

    tagsView.addTags(self.viewModel.selectedTags.flatMap { $0.title } )
    
    tagsView.tintColor = theme.colorNumber9()
    tagsView.textColor = theme.colorNumber20()
    tagsView.selectedColor = theme.colorNumber25()
    tagsView.selectedTextColor = theme.colorNumber23()
    tagsView.font = FontDynamicType.caption3.font
    tagsView.padding.left = 0

    tagsView.onVerifyTag = { [weak self] field, candidate in
      guard let strongSelf = self else {
        return false
      }
      return strongSelf.viewModel.canLink
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
      //TODO: Handle error
      guard let strongSelf = self else {
        return
      }
      let text = tag.text
      if strongSelf.viewModel.hasTag(with: text) {
        _ = TagAPI.linkTag(for: strongSelf.viewModel.contentIdentifier, with: text, completion: { (success, error) in
          guard success else {
            //TODO: if we get `no more tags are allowed error` we should set viewModel.canLink = false
            return
          }
        })

      } else {
        //Create (user hit return)
        let linkedTags = strongSelf.viewModel.selectedTags
        let allTags = linkedTags + [text].map {
          let tag = Tag()
          tag.title = $0
          return tag
        }
        strongSelf.viewModel.selectedTags = allTags
        //TODO: change .draft value below to a proper status value
        _ = TagAPI.replaceTags(for: strongSelf.viewModel.contentIdentifier, with: allTags.flatMap { $0.title }, status: .draft, completion: { (success, post, error) in
          guard success, let post = post, let tags = post.tags else {
            return
          }
          //Previously we were setting the tags on success 
          //After BMA-1683 we asked to consider the tag is linked
          strongSelf.viewModel.selectedTags = tags
        })
      }
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
        self.viewModel.resetTags()
        return
      }
      self.viewModel.set(tags)
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

//MARK: - Localizable implementation
extension LinkTagsViewController: Localizable {
  func applyLocalization() {
    self.title = Strings.tags()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

extension LinkTagsViewController: Themeable {
  
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    self.view.backgroundColor = theme.colorNumber2()
    self.navigationController?.navigationBar.barTintColor = theme.colorNumber2()
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
    let theme = ThemeManager.shared.currentTheme
    cell.textLabel?.text = self.viewModel.values(forRowAt: indexPath)
    cell.textLabel?.font = FontDynamicType.caption1.font
    cell.textLabel?.textColor = theme.defaultTextColor()
    cell.detailTextLabel?.font = FontDynamicType.caption3.font
    cell.detailTextLabel?.text = ""
    cell.detailTextLabel?.textColor = theme.defaultGrayedTextColor()
    cell.indentationWidth = 39
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.viewModel.append(self.viewModel.getFetchedTag(at: indexPath.row))
    if let tagTitle = self.viewModel.selectedTags.last?.title {
      self.tagsView.addTag(tagTitle)
    }
    self.viewModel.resetTags()
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 43
  }
}
