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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRows(for: section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.reuseIdentifier) ?? UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? BookTableViewCell else {
      return
    }
    let values = viewModel.selectionValues(for: indexPath)
    cell.productImageURL = values.imageURL
    cell.bookTitle = values.bookTitle
    cell.authorName = values.authorName
    cell.productType = values.productType
    cell.price = values.price
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return BookTableViewCell.minimumHeight
  }
}
