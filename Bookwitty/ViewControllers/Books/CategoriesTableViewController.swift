//
//  CategoriesTableViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
  let viewModel = CategoriesTableViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(DisclosureTableViewCell.nib,
                       forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    
    // Uncomment the following line to preserve selection between presentations
    clearsSelectionOnViewWillAppear = true
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return viewModel.numberOfSections
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return viewModel.numberOfRowsForSection(section: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: DisclosureTableViewCell.identifier, for: indexPath)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? DisclosureTableViewCell else {
      return
    }
    cell.label.text = viewModel.data(forCellAtIndexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
}
