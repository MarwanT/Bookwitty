//
//  LinkTopicsViewController.swift
//  Bookwitty
//
//  Created by ibrahim on 10/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import WSTagsField

class LinkTopicsViewController: UIViewController {
  let viewModel = LinkTopicsViewModel()
  @IBOutlet weak var tagsView: WSTagsField!
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initializeComponents()
  }
  
  private func initializeComponents() {
    let doneButton = UIBarButtonItem(title: Strings.done(), style: .plain, target: self, action: #selector(doneButtonTouchUpInside(_:)))
    doneButton.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
    self.navigationItem.rightBarButtonItem = doneButton
    
    self.tableView.tableFooterView = UIView()
    self.tableView.backgroundColor = .clear
  }
  
  @objc private func doneButtonTouchUpInside(_ sender:UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension LinkTopicsViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
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
    cell.textLabel?.text = self.viewModel.values(forRowAt: indexPath)
    cell.textLabel?.font = FontDynamicType.caption1.font
    cell.detailTextLabel?.text = ""
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.viewModel.append(self.viewModel.topics[indexPath.row])
    self.tagsView.addTags(self.viewModel.selectedTopics.flatMap { $0.title })
    self.viewModel.topics = []
    tableView.reloadData()
  }
}
