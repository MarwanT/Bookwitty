//
//  LinkTopicsViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField

protocol LinkTopicsViewControllerDelegate: class {
  func linkTopics(viewController: LinkTopicsViewController, didLink topics: [Topic])
}

class LinkTopicsViewController: UIViewController {
  let viewModel = LinkTopicsViewModel()
  @IBOutlet weak var tagsView: WSTagsField!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewBottomConstraintToSuperview: NSLayoutConstraint!
  @IBOutlet weak var separatorView: UIView!
  
  var delegate: LinkTopicsViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initializeComponents()
    self.addKeyboardNotifications()
    self.applyTheme()
    self.tagsView.beginEditing() // becomeFirstResponder
  }
  
  private func initializeComponents() {
    let doneButton = UIBarButtonItem(title: Strings.done(), style: .plain, target: self, action: #selector(doneButtonTouchUpInside(_:)))
    doneButton.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    self.navigationItem.rightBarButtonItem = doneButton
    self.navigationItem.backBarButtonItem = .back
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = .clear
    self.separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    tagsView.onVerifyTag = { field, candidate in
      let canLink =  self.viewModel.canLink
      let hasSimilarTitle = self.viewModel.hasSimilarTitle(candidate)
      return canLink && hasSimilarTitle
    }
    tagsView.onDidChangeText = { field, text in
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(#selector(LinkTopicsViewController.reload), with: text, afterDelay: 0.5)
    }
    tagsView.onShouldReturn = { _ in
      return false
    }
    tagsView.onDidRemoveTag = { _, tag in
      guard let topic = self.viewModel.unselectTopic(with: tag.text), let topicIdentifier = topic.id else {
        return
      }
      _ = ContentAPI.unlinkContent(for: self.viewModel.contentIdentifier, with: topicIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
    }
  }
  
  @objc private func doneButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.delegate?.linkTopics(viewController: self, didLink: self.viewModel.getSelectedTopics)
  }
  
  @objc private func reload(with text: String?) {
    guard let text = text, text.characters.count > 0 else {
      return
    }
    
    self.viewModel.filter.query = text
    //Perform request
    _ = SearchAPI.search(filter: self.viewModel.filter, page: nil) { (success, topics, _, _, error) in
      guard success, let topics = topics as? [Topic] else {
        self.viewModel.setTopics([])
        return
      }
      self.viewModel.setTopics(topics)
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

extension LinkTopicsViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

extension LinkTopicsViewController {
  func viewTopicViewController(with topic: Topic) {
    let topicViewController = TopicViewController()
    topicViewController.initialize(with: topic)
    topicViewController.delegate = self
    if self.viewModel.isSelected(topic) {
      topicViewController.navigationItemMode = .action(.unlink)
    } else {
      topicViewController.navigationItemMode = .action(.link)
    }
    navigationController?.pushViewController(topicViewController, animated: true)
  }
}

extension LinkTopicsViewController: TopicViewControllerDelegate {
  func topic(viewController: TopicViewController, didRequest action: TopicAction, for topic: Topic) {
    switch action {
    case .link:
      self.viewModel.select(topic)
      self.tagsView.addTags(self.viewModel.titlesForSelectedTopics)
      guard let topicIdentifier = topic.id else {
        return
      }
      _ = ContentAPI.linkContent(for: self.viewModel.contentIdentifier, with: topicIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
    case .unlink:
      self.viewModel.unselect(topic)
      guard let topicIdentifier = topic.id else {
        return
      }
      _ = ContentAPI.unlinkContent(for: self.viewModel.contentIdentifier, with: topicIdentifier, completion: { (success, error) in
        guard success else {
          return
        }
      })
      if let title = topic.title {
        self.tagsView.removeTag(title)
      }
    }
    self.viewModel.setTopics([])
    self.tableView.reloadData()
    
    _ = self.navigationController?.popViewController(animated: true)
  }
}

extension LinkTopicsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.numberOfItemsInSection(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "tagCellIdentifier", for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let topic = self.viewModel.values(for: indexPath.row).topic
    cell.textLabel?.text = topic?.title
    cell.textLabel?.font = FontDynamicType.caption1.font
    cell.detailTextLabel?.text = ""
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let topic = self.viewModel.values(for: indexPath.row).topic else {
      return
    }
    self.viewTopicViewController(with: topic)
    tableView.reloadData()
  }
}
