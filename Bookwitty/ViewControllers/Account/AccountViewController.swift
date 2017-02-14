//
//  AccountViewController.swift
//  Bookwitty
//
//  Created by charles on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  fileprivate let viewModel = AccountViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.title = self.viewModel.viewControllerTitle
  }

  private func initializeComponents() {
    tableView.register(DisclosureTableViewCell.nib, forCellReuseIdentifier: DisclosureTableViewCell.identifier)
  }
}

extension AccountViewController {


}
