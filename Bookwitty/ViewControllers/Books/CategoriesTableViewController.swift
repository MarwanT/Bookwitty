//
//  CategoriesTableViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol CategoriesTableViewDelegate: class {
  func categoriesTableViewDidSelectCategory(_ viewController: CategoriesTableViewController, category: Category)
}

class CategoriesTableViewController: UITableViewController {
  let viewModel = CategoriesTableViewModel()
  
  weak var delegate: CategoriesTableViewDelegate? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(DisclosureTableViewCell.nib,
                       forCellReuseIdentifier: DisclosureTableViewCell.identifier)
    
    // Uncomment the following line to preserve selection between presentations
    clearsSelectionOnViewWillAppear = true
    
    applyTheme()
    
    if delegate == nil {
      delegate = self
    }
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = viewModel.category(forCellAtIndexPath: indexPath)
    delegate?.categoriesTableViewDidSelectCategory(self, category: category)
  }
}

extension CategoriesTableViewController: Themeable {
  func applyTheme() {
    let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
    
    tableView.separatorColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    tableView.separatorInset = UIEdgeInsets(
      top: 0, left: leftMargin, bottom: 0, right: 0)
  }
}

extension CategoriesTableViewController: CategoriesTableViewDelegate {
  func categoriesTableViewDidSelectCategory(_ viewController: CategoriesTableViewController, category: Category) {
    // TODO: Implement default navigation
  }
}
