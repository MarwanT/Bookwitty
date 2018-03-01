//
//  LinkPagesViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField

protocol LinkPagesViewControllerDelegate: class {
  func linkPages(viewController: LinkPagesViewController, didLink pages: [ModelCommonProperties])
}

class LinkPagesViewController: UIViewController {
  let viewModel = LinkPagesViewModel()
  @IBOutlet weak var tagsView: WSTagsField!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewBottomConstraintToSuperview: NSLayoutConstraint!
  @IBOutlet weak var separatorView: UIView!
  
  var delegate: LinkPagesViewControllerDelegate?
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initializeComponents()
    self.addKeyboardNotifications()
    self.applyTheme()
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
    self.navigationItem.backBarButtonItem = .back
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = .clear
    self.tableView.separatorInset = UIEdgeInsets.zero
    self.tableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    self.separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    tagsView.delimiter = "\n"
    tagsView.beginEditing() // becomeFirstResponder

    tagsView.addTags(self.viewModel.getSelectedPages.flatMap { $0.title } )

    tagsView.onVerifyTag = { [weak self] field, candidate in
      guard let strongSelf = self else {
        return false
      }
      let canLink =  strongSelf.viewModel.canLink
      let hasSimilarTitle = strongSelf.viewModel.hasSimilarTitle(candidate)
      return canLink && hasSimilarTitle
    }
    tagsView.onDidChangeText = { [weak self] field, text in
      guard let strongSelf = self else {
        return
      }
      NSObject.cancelPreviousPerformRequests(withTarget: strongSelf)
      strongSelf.perform(#selector(LinkPagesViewController.reload), with: text, afterDelay: 0.5)
    }
    tagsView.onShouldReturn = { _ in
      return false
    }
    tagsView.onDidRemoveTag = { [weak self] _, tag in
      guard let strongSelf = self else {
        return
      }
      
      guard let page = strongSelf.viewModel.unselectPage(with: tag.text), let pageIdentifier = page.id else {
        return
      }
      _ = ContentAPI.unlinkContent(for: strongSelf.viewModel.contentIdentifier, with: pageIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
    }
  }
  
  @objc private func doneButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.delegate?.linkPages(viewController: self, didLink: self.viewModel.getSelectedPages)
  }
  
  @objc private func reload(with text: String?) {
    guard let text = text, text.characters.count > 0 else {
      return
    }
    
    self.viewModel.filter.query = text
    //Perform request
    _ = SearchAPI.autocomplete(filter: self.viewModel.filter, page: nil) { (success, pages, _, _, error) in
      guard success, let pages = pages?.flatMap({ $0 as? ModelCommonProperties }) else {
        self.viewModel.setPages([])
        return
      }
      self.viewModel.setPages(pages)
      self.tableView.reloadData()
    }
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
extension LinkPagesViewController: Localizable {
  func applyLocalization() {
    self.title = Strings.topic()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

extension LinkPagesViewController: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    self.view.backgroundColor = theme.colorNumber2()
    self.navigationController?.navigationBar.barTintColor = theme.colorNumber2()

    tagsView.tintColor = theme.colorNumber9()
    tagsView.textColor = theme.colorNumber20()
    tagsView.selectedColor = theme.colorNumber25()
    tagsView.selectedTextColor = theme.colorNumber23()
    tagsView.font = FontDynamicType.caption1.font
    tagsView.padding.left = 0
    tagsView.padding.bottom = 0
  }
}

extension LinkPagesViewController {
  func viewTopicViewController(with page: ModelCommonProperties) {
    let topicViewController = TopicViewController()
    topicViewController.initialize(with: page)
    topicViewController.delegate = self
    if self.viewModel.isSelected(page) {
      topicViewController.navigationItemMode = .action(.unlink)
    } else {
      topicViewController.navigationItemMode = .action(.link)
    }
    navigationController?.pushViewController(topicViewController, animated: true)
  }
}

extension LinkPagesViewController: TopicViewControllerDelegate {
  func topic(viewController: TopicViewController, didRequest action: PageAction, for page: ModelCommonProperties) {
    switch action {
    case .link:
      self.viewModel.select(page)
      self.tagsView.addTags(self.viewModel.titlesForSelectedPages)
      guard let pageIdentifier = page.id else {
        return
      }
      _ = ContentAPI.linkContent(for: self.viewModel.contentIdentifier, with: pageIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
    case .unlink:
      self.viewModel.unselect(page)
      guard let pageIdentifier = page.id else {
        return
      }
      _ = ContentAPI.unlinkContent(for: self.viewModel.contentIdentifier, with: pageIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
      if let title = page.title {
        self.tagsView.removeTag(title)
      }
    }
    self.viewModel.setPages([])
    self.tableView.reloadData()
    
    _ = self.navigationController?.popViewController(animated: true)
  }
}

extension LinkPagesViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfItemsInSection(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "tagCellIdentifier", for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let theme = ThemeManager.shared.currentTheme
    let page = self.viewModel.values(for: indexPath.row).page
    cell.textLabel?.text = page?.title
    cell.textLabel?.font = FontDynamicType.caption1.font
    cell.textLabel?.textColor = theme.defaultTextColor()
    cell.detailTextLabel?.font = FontDynamicType.caption3.font
    cell.detailTextLabel?.text = ""
    cell.detailTextLabel?.textColor = theme.defaultGrayedTextColor()
    cell.indentationWidth = 39
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let page = self.viewModel.values(for: indexPath.row).page else {
      return
    }
    self.viewTopicViewController(with: page)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 43
  }
}
