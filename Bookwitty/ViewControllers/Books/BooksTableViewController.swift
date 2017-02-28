//
//  BooksTableViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/21/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class BooksTableViewController: UITableViewController {
  var viewModel = BooksTableViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(BookTableViewCell.nib, forCellReuseIdentifier: BookTableViewCell.reuseIdentifier)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 0
  }
}
