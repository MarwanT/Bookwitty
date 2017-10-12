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
