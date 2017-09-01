//
//  EmailSettingsViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/01.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class EmailSettingsViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  fileprivate let viewModel = EmailSettingsViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    
  }
}

extension EmailSettingsViewController: Themeable {
  func applyTheme() {
    tableView.backgroundColor = UIColor.clear
    view.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}
