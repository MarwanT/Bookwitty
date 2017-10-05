//
//  SelectPenNameViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/05.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class SelectPenNameViewController: UIViewController {

  fileprivate let viewModel = SelectPenNameViewModel()

  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
  }

  fileprivate func initializeComponents() {
    tableView.tableFooterView = UIView.defaultSeparator(useAutoLayout: false)
  }
}
