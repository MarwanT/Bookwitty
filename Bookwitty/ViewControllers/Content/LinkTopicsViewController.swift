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
  }
}

extension LinkTopicsViewController: Themeable {
  func applyTheme() {
    self.view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}
